/*
 * Published under MIT license, see README.
 */

#include <stdbool.h>
#include <ruby.h>
#include <newt.h>

static VALUE initialized = Qfalse;

static VALUE mNewt;
static VALUE mScreen;
static VALUE cWidget;
static VALUE cForm;
static VALUE cExitStruct;
static VALUE cLabel;
static VALUE cCompactButton;
static VALUE cButton;
static VALUE cCheckbox;
static VALUE cRadioButton;

static VALUE cListbox;
static VALUE cCheckboxTree;
static VALUE cCheckboxTreeMulti;
static VALUE cTextbox;
static VALUE cTextboxReflowed;
static VALUE cEntry;
static VALUE cScale;
static VALUE cGrid;

static VALUE rb_ext_sCallback;
static struct newtColors newtColors;

#define PTR2NUM(ptr)      (SIZET2NUM((size_t)(ptr)))
#define SYMBOL(str)       (ID2SYM(rb_intern(str)))
#define PROC_CALL         (rb_intern("call"))
#define RECEIVER(context) (rb_funcall((context), rb_intern("receiver"), 0))
#define IVAR_DATA   (rb_intern("newt_ivar_data"))
#define IVAR_COLS   (rb_intern("newt_ivar_cols"))
#define IVAR_ROWS   (rb_intern("newt_ivar_rows"))
#define CVAR_SUSPEND_CALLBACK (rb_intern("newt_cvar_suspend_callback"))
#define CVAR_HELP_CALLBACK    (rb_intern("newt_cvar_help_callback"))
#define IVAR_FILTER_CALLBACK  (rb_intern("newt_ivar_filter_callback"))
#define IVAR_WIDGET_CALLBACK  (rb_intern("newt_ivar_widget_callback"))

#define ARG_ERROR(given, expected) \
  rb_raise(rb_eArgError, "wrong number of arguments (given %d, expected %s)", \
           (given), (expected))

#define INIT_GUARD() do { \
  if (initialized == Qfalse) { \
      rb_raise(rb_eRuntimeError, "libnewt is not initialized"); \
  } \
} while (0)

#define FLAG_GC_FREE       (1 << 0)
#define FLAG_ADDED_TO_FORM (1 << 1)

typedef struct Widget_data_s Widget_data;
struct Widget_data_s {
  VALUE self;
  VALUE components;
  newtComponent co;
  int flags;
};

typedef struct rb_newt_ExitStruct_s rb_newt_ExitStruct;
struct rb_newt_ExitStruct_s {
    struct newtExitStruct es;
    VALUE components;
};

static void free_widget(void *ptr);
static void form_destroy(Widget_data *form);

static const rb_data_type_t Widget_type = {
  "newtComponent",
  { NULL, free_widget, NULL },
  NULL, NULL,
  RUBY_TYPED_FREE_IMMEDIATELY
};

#define Make_Widget(klass, component) \
  (widget_data_make((klass), (component), true))

#define Make_Widget_Ref(klass, component) \
  (widget_data_make((klass), (component), false));

#define Get_Widget_Data(self, data) \
  ((data) = widget_data_get((self)))

#define Get_newtComponent(self, component) do { \
  Widget_data *data; \
  INIT_GUARD(); \
  Get_Widget_Data((self), data); \
  (component) = data->co; \
} while (0)

static inline VALUE widget_data_make(VALUE klass, newtComponent co, bool gc_free)
{
  Widget_data *data;
  VALUE self = TypedData_Make_Struct(klass, Widget_data, &Widget_type, data);
  data->self = self;
  data->components = Qnil;
  data->co = co;
  data->flags |= gc_free;
  return self;
}

static inline Widget_data *widget_data_get(VALUE self)
{
  VALUE str;
  Widget_data *data;

  TypedData_Get_Struct(self, Widget_data, &Widget_type, data);
  if (data == NULL) {
    str = rb_inspect(self);
    rb_raise(rb_eRuntimeError, "%s has already been destroyed",
             StringValuePtr(str));
  }
  return data;
}

NORETURN(static VALUE newt_s_alloc(VALUE klass));
static VALUE newt_s_alloc(VALUE klass)
{
  rb_raise(rb_eTypeError, "allocator undefined for %"PRIsVALUE, klass);
  UNREACHABLE_RETURN(Qnil);
}

static void free_widget(void *ptr)
{
  Widget_data *data = (Widget_data *) ptr;

  if (rb_obj_is_kind_of(data->self, cForm)) {
    form_destroy(data);
  } else if (data->flags & FLAG_GC_FREE) {
    newtComponentDestroy(data->co);
  }
  free(data);
}

static void form_destroy(Widget_data *form)
{
  if (form->flags & FLAG_GC_FREE) newtFormDestroy(form->co);
  rb_gc_unregister_address(&form->components);
}

static void rb_newt_es_free(rb_newt_ExitStruct *rb_es)
{
  rb_gc_unregister_address(&rb_es->components);
  xfree(rb_es);
}

#define Data_Attach(self, data) do { \
  VALUE ivar = get_newt_ivar((self)); \
  rb_ary_push(ivar, (data)); \
} while (0)

static inline VALUE get_newt_ivar(VALUE self) {
  VALUE ivar_data;

  if (rb_ivar_defined(self, IVAR_DATA)) {
    ivar_data = rb_ivar_get(self, IVAR_DATA);
  } else {
    ivar_data = rb_ary_new();
    rb_ivar_set(self, IVAR_DATA, ivar_data);
  }
  return ivar_data;
}

static VALUE rb_ext_Delay(VALUE self, VALUE usecs)
{
  newtDelay(NUM2UINT(usecs));
  return Qnil;
}

static VALUE rb_ext_ReflowText(VALUE self, VALUE text, VALUE width, VALUE flexDown, VALUE flexUp)
{
  char *p;
  int actualWidth, actualHeight;

  p = newtReflowText(StringValuePtr(text), NUM2INT(width), NUM2INT(flexDown),
                     NUM2INT(flexUp), &actualWidth, &actualHeight);

  return rb_ary_new_from_args(3, rb_str_new2(p), INT2NUM(actualWidth), INT2NUM(actualHeight));
}

static VALUE rb_ext_ColorSetCustom(VALUE self, VALUE id)
{
  return INT2NUM(NEWT_COLORSET_CUSTOM(NUM2INT(id)));
}

static VALUE rb_ext_Screen_Init()
{
  if (initialized == Qtrue)
    return Qnil;

  newtInit();
  memcpy(&newtColors, &newtDefaultColorPalette, sizeof(struct newtColors));
  initialized = Qtrue;
  return Qnil;
}

static VALUE rb_ext_Screen_new()
{
  rb_ext_Screen_Init();
  newtCls();
  return Qnil;
}

static VALUE rb_ext_Screen_Cls()
{
  INIT_GUARD();
  newtCls();
  return Qnil;
}

static VALUE rb_ext_Screen_Finished()
{
  newtFinished();
  initialized = Qfalse;
  return Qnil;
}

static VALUE rb_ext_Screen_WaitForKey()
{
  INIT_GUARD();
  newtWaitForKey();
  return Qnil;
}

static VALUE rb_ext_Screen_ClearKeyBuffer()
{
  INIT_GUARD();
  newtClearKeyBuffer();
  return Qnil;
}

static VALUE rb_ext_Screen_OpenWindow(VALUE self, VALUE left, VALUE top,
    VALUE width, VALUE height, VALUE title)
{
  INIT_GUARD();
  return INT2NUM(newtOpenWindow(NUM2INT(left), NUM2INT(top), NUM2INT(width),
                                NUM2INT(height), StringValuePtr(title)));
}

static VALUE rb_ext_Screen_CenteredWindow(VALUE self, VALUE width, VALUE height, VALUE title)
{
  INIT_GUARD();
  return INT2NUM(newtCenteredWindow(NUM2INT(width), NUM2INT(height), StringValuePtr(title)));
}

static VALUE rb_ext_Screen_PopWindow(VALUE self)
{
  INIT_GUARD();
  newtPopWindow();
  return Qnil;
}

int rb_ext_Colors_callback_function(VALUE key, VALUE val, VALUE in)
{
  struct newtColors *colors;

  colors = (struct newtColors *) in;
  Check_Type(key, T_SYMBOL);

  if (key == SYMBOL("rootFg"))
    colors->rootFg = StringValuePtr(val);

  else if (key == SYMBOL("rootBg"))
    colors->rootBg = StringValuePtr(val);

  else if (key == SYMBOL("borderFg"))
    colors->borderFg = StringValuePtr(val);

  else if (key == SYMBOL("borderBg"))
    colors->borderBg = StringValuePtr(val);

  else if (key == SYMBOL("windowFg"))
    colors->windowFg = StringValuePtr(val);

  else if (key == SYMBOL("windowBg"))
    colors->windowBg = StringValuePtr(val);

  else if (key == SYMBOL("shadowFg"))
    colors->shadowFg = StringValuePtr(val);

  else if (key == SYMBOL("shadowBg"))
    colors->shadowBg = StringValuePtr(val);

  else if (key == SYMBOL("titleFg"))
    colors->titleFg = StringValuePtr(val);

  else if (key == SYMBOL("titleBg"))
    colors->titleBg = StringValuePtr(val);

  else if (key == SYMBOL("buttonFg"))
    colors->buttonFg = StringValuePtr(val);

  else if (key == SYMBOL("buttonBg"))
    colors->buttonBg = StringValuePtr(val);

  else if (key == SYMBOL("actButtonFg"))
    colors->actButtonFg = StringValuePtr(val);

  else if (key == SYMBOL("actButtonBg"))
    colors->actButtonBg = StringValuePtr(val);

  else if (key == SYMBOL("checkboxFg"))
    colors->checkboxFg = StringValuePtr(val);

  else if (key == SYMBOL("checkboxBg"))
    colors->checkboxBg = StringValuePtr(val);

  else if (key == SYMBOL("actCheckboxFg"))
    colors->actCheckboxFg = StringValuePtr(val);

  else if (key == SYMBOL("actCheckboxBg"))
    colors->actCheckboxBg = StringValuePtr(val);

  else if (key == SYMBOL("entryFg"))
    colors->entryFg = StringValuePtr(val);

  else if (key == SYMBOL("entryBg"))
    colors->entryBg = StringValuePtr(val);

  else if (key == SYMBOL("labelFg"))
    colors->labelFg = StringValuePtr(val);

  else if (key == SYMBOL("labelBg"))
    colors->labelBg = StringValuePtr(val);

  else if (key == SYMBOL("listboxFg"))
    colors->listboxFg = StringValuePtr(val);

  else if (key == SYMBOL("listboxBg"))
    colors->listboxBg = StringValuePtr(val);

  else if (key == SYMBOL("actListboxFg"))
    colors->actListboxFg = StringValuePtr(val);

  else if (key == SYMBOL("actListboxBg"))
    colors->actListboxBg = StringValuePtr(val);

  else if (key == SYMBOL("textboxFg"))
    colors->textboxFg = StringValuePtr(val);

  else if (key == SYMBOL("textboxBg"))
    colors->textboxBg = StringValuePtr(val);

  else if (key == SYMBOL("actTextboxFg"))
    colors->actTextboxFg = StringValuePtr(val);

  else if (key == SYMBOL("actTextboxBg"))
    colors->actTextboxBg = StringValuePtr(val);

  else if (key == SYMBOL("helpLineFg"))
    colors->helpLineFg = StringValuePtr(val);

  else if (key == SYMBOL("helpLineBg"))
    colors->helpLineBg = StringValuePtr(val);

  else if (key == SYMBOL("rootTextBg"))
    colors->rootTextBg = StringValuePtr(val);

  else if (key == SYMBOL("emptyScale"))
    colors->emptyScale = StringValuePtr(val);

  else if (key == SYMBOL("fullScale"))
    colors->fullScale = StringValuePtr(val);

  else if (key == SYMBOL("disabledEntryFg"))
    colors->disabledEntryFg = StringValuePtr(val);

  else if (key == SYMBOL("disabledEntryBg"))
    colors->disabledEntryBg = StringValuePtr(val);

  else if (key == SYMBOL("compactButtonFg"))
    colors->compactButtonFg = StringValuePtr(val);

  else if (key == SYMBOL("compactButtonBg"))
    colors->compactButtonBg = StringValuePtr(val);

  else if (key == SYMBOL("actSelListboxFg"))
    colors->actSelListboxFg = StringValuePtr(val);

  else if (key == SYMBOL("actSelListboxBg"))
    colors->actSelListboxBg = StringValuePtr(val);

  else if (key == SYMBOL("selListboxFg"))
    colors->selListboxFg = StringValuePtr(val);

  else if (key == SYMBOL("selListboxBg"))
    colors->selListboxBg = StringValuePtr(val);

  return ST_CONTINUE;
}

static VALUE rb_ext_Screen_SetColors(VALUE self, VALUE colors)
{
  Check_Type(colors, T_HASH);
  rb_hash_foreach(colors, rb_ext_Colors_callback_function, (VALUE) &newtColors);

  INIT_GUARD();
  newtSetColors(newtColors);
  return Qnil;
}

static VALUE rb_ext_Screen_SetColor(VALUE self, VALUE colorset, VALUE fg, VALUE bg)
{
  INIT_GUARD();
  newtSetColor(NUM2INT(colorset), StringValuePtr(fg), StringValuePtr(bg));
  return Qnil;
}

static VALUE rb_ext_Screen_Resume()
{
  INIT_GUARD();
  newtResume();
  return Qnil;
}

static VALUE rb_ext_Screen_Suspend()
{
  INIT_GUARD();
  newtSuspend();
  return Qnil;
}

static VALUE rb_ext_Screen_Refresh()
{
  INIT_GUARD();
  newtRefresh();
  return Qnil;
}

static VALUE rb_ext_Screen_DrawRootText(VALUE self, VALUE col, VALUE row, VALUE text)
{
  INIT_GUARD();
  newtDrawRootText(NUM2INT(col), NUM2INT(row), StringValuePtr(text));
  return Qnil;
}

static VALUE rb_ext_Screen_PushHelpLine(VALUE self, VALUE text)
{
  INIT_GUARD();
  newtPushHelpLine(StringValuePtr(text));

  return Qnil;
}

static VALUE rb_ext_Screen_RedrawHelpLine(VALUE self)
{
  INIT_GUARD();
  newtRedrawHelpLine();
  return Qnil;
}

static VALUE rb_ext_Screen_PopHelpLine(VALUE self)
{
  INIT_GUARD();
  newtPopHelpLine();
  return Qnil;
}

static VALUE rb_ext_Screen_Bell(VALUE self)
{
  INIT_GUARD();
  newtBell();
  return Qnil;
}

static VALUE rb_ext_Screen_CursorOff(VALUE self)
{
  INIT_GUARD();
  newtCursorOff();
  return Qnil;
}

static VALUE rb_ext_Screen_CursorOn(VALUE self)
{
  INIT_GUARD();
  newtCursorOn();
  return Qnil;
}

static VALUE rb_ext_Screen_Size(VALUE self)
{
  int cols, rows;

  INIT_GUARD();
  newtGetScreenSize(&cols, &rows);
  return rb_ary_new_from_args(2, INT2NUM(cols), INT2NUM(rows));
}

static VALUE rb_ext_Screen_WinMessage(VALUE self, VALUE title, VALUE button, VALUE text)
{
  INIT_GUARD();
  newtWinMessage(StringValuePtr(title), StringValuePtr(button), StringValuePtr(text));
  return Qnil;
}

static VALUE rb_ext_Screen_WinChoice(VALUE self, VALUE title, VALUE button1, VALUE button2, VALUE text)
{
  int result;

  INIT_GUARD();
  result = newtWinChoice(StringValuePtr(title), StringValuePtr(button1),
                         StringValuePtr(button2), StringValuePtr(text));
  return INT2NUM(result);
}

static VALUE rb_ext_Screen_WinMenu(VALUE self, VALUE args)
{
  char **cptr;
  char *title, *text, *button1, *button2;

  int len, i, listItem;
  int width, flexDown, flexUp, maxHeight;

  len = RARRAY_LENINT(args);
  if (len < 8 || len > 9)
    ARG_ERROR(len, "8..9");

  INIT_GUARD();
  title = StringValuePtr(RARRAY_PTR(args)[0]);
  text = StringValuePtr(RARRAY_PTR(args)[1]);
  width = NUM2INT(RARRAY_PTR(args)[2]);
  flexDown = NUM2INT(RARRAY_PTR(args)[3]);
  flexUp = NUM2INT(RARRAY_PTR(args)[4]);
  maxHeight = NUM2INT(RARRAY_PTR(args)[5]);

  Check_Type(RARRAY_PTR(args)[6], T_ARRAY);

  len = RARRAY_LENINT(RARRAY_PTR(args)[6]);
  cptr = ALLOCA_N(char*, len + 1);
  for (i = 0; i < len; i++) {
    Check_Type(RARRAY_PTR(RARRAY_PTR(args)[6])[i], T_STRING);
    cptr[i] = StringValuePtr(RARRAY_PTR(RARRAY_PTR(args)[6])[i]);
  }
  cptr[len] = NULL;

  button1 = StringValuePtr(RARRAY_PTR(args)[7]);
  button2 = (len == 9) ? StringValuePtr(RARRAY_PTR(args)[8]) : NULL;

  newtWinMenu(title, text, width, flexDown, flexUp, maxHeight, cptr, &listItem, button1, button2, NULL);
  return INT2NUM(listItem);
}

static VALUE rb_ext_Screen_WinEntries(VALUE self, VALUE args)
{
  VALUE ary;
  struct newtWinEntry *items;
  char *title, *text, *button1, *button2;
  int len, i;
  int width, flexDown, flexUp, dataWidth;
  char *entries[10];

  len = RARRAY_LENINT(args);
  if (len < 8 || len > 9)
    ARG_ERROR(len, "8..9");

  INIT_GUARD();
  title = StringValuePtr(RARRAY_PTR(args)[0]);
  text = StringValuePtr(RARRAY_PTR(args)[1]);
  width = NUM2INT(RARRAY_PTR(args)[2]);
  flexDown = NUM2INT(RARRAY_PTR(args)[3]);
  flexUp = NUM2INT(RARRAY_PTR(args)[4]);
  dataWidth = NUM2INT(RARRAY_PTR(args)[5]);
  button1 = StringValuePtr(RARRAY_PTR(args)[7]);
  button2 = (len == 9) ? StringValuePtr(RARRAY_PTR(args)[8]) : NULL;

  Check_Type(RARRAY_PTR(args)[6], T_ARRAY);
  len = RARRAY_LENINT(RARRAY_PTR(args)[6]);
  if (len > 8) ARG_ERROR(len, "8 or less");
  memset(entries, 0, sizeof(entries));
  items = ALLOCA_N(struct newtWinEntry, len + 1);
  for (i = 0; i < len; i++) {
    Check_Type(RARRAY_PTR(RARRAY_PTR(args)[6])[i], T_STRING);
    items[i].text = StringValuePtr(RARRAY_PTR(RARRAY_PTR(args)[6])[i]);
    items[i].value = entries + i;
    items[i].flags = 0;
  }
  items[len].text = NULL;
  items[len].value = NULL;
  items[len].flags = 0;

  ary = rb_ary_new();
  newtWinEntries(title, text, width, flexDown, flexUp, dataWidth, items, button1, button2, NULL);
  for (i = 0; i < len; i++) { rb_ary_push(ary, rb_str_new2(entries[i])); }
  return ary;
}

void rb_ext_Screen_suspend_callback_function(void *cb)
{
  VALUE context, callback, data;

  context = RSTRUCT_GET((VALUE) cb, 1);
  callback = RSTRUCT_GET((VALUE) cb, 2);
  data = RSTRUCT_GET((VALUE) cb, 3);

  if (SYMBOL_P(callback)) {
    rb_funcall(RECEIVER(context), SYM2ID(callback), 1, data);
  } else {
    rb_funcall(callback, PROC_CALL, 1, data);
  }
}

void rb_ext_Screen_help_callback_function(newtComponent co, void *data)
{
  VALUE widget, cb;
  VALUE context, callback;

  widget = Make_Widget_Ref(cForm, co);
  cb = rb_cvar_get(mScreen, CVAR_HELP_CALLBACK);
  context = RSTRUCT_GET((VALUE) cb, 1);
  callback = RSTRUCT_GET((VALUE) cb, 2);

  if (SYMBOL_P(callback)) {
    rb_funcall(RECEIVER(context), SYM2ID(callback), 2, widget, (VALUE) data);
  } else {
    rb_funcall(callback, PROC_CALL, 2, widget, (VALUE) data);
  }
}

void rb_ext_Widget_callback_function(newtComponent co, void *cb)
{
  VALUE widget, context, callback, data;

  widget = RSTRUCT_GET((VALUE) cb, 0);
  context = RSTRUCT_GET((VALUE) cb, 1);
  callback = RSTRUCT_GET((VALUE) cb, 2);
  data = RSTRUCT_GET((VALUE) cb, 3);

  if (SYMBOL_P(callback)) {
    rb_funcall(RECEIVER(context), SYM2ID(callback), 2, widget, data);
  } else {
    rb_funcall(callback, PROC_CALL, 2, widget, data);
  }
}

int rb_ext_Entry_filter_function(newtComponent co, void *cb, int ch, int cursor)
{
  VALUE widget, context, callback, data;
  VALUE vch, vcursor;
  VALUE rv;

  widget = RSTRUCT_GET((VALUE) cb, 0);
  context = RSTRUCT_GET((VALUE) cb, 1);
  callback = RSTRUCT_GET((VALUE) cb, 2);
  data = RSTRUCT_GET((VALUE) cb, 3);
  vch = INT2NUM(ch);
  vcursor = INT2NUM(cursor);

  if (SYMBOL_P(callback)) {
    rv = rb_funcall(RECEIVER(context), SYM2ID(callback), 4, widget, data, vch, vcursor);
  } else {
    rv = rb_funcall(callback, PROC_CALL, 4, widget, data, vch, vcursor);
  }
  return (NIL_P(rv) || !RB_TYPE_P(rv, T_FIXNUM)) ? 0 : NUM2INT(rv);
}

static VALUE rb_ext_Screen_SuspendCallback(int argc, VALUE *argv, VALUE self)
{
  VALUE cb, data = Qnil;

  if (argc < 1 || argc > 2)
    ARG_ERROR(argc, "1 or 2");

  INIT_GUARD();
  if (argc == 2)
    data = argv[1];

  cb = rb_struct_new(rb_ext_sCallback, self, rb_binding_new(), argv[0], data, NULL);
  rb_obj_freeze(cb);
  rb_cvar_set(self, CVAR_SUSPEND_CALLBACK, cb);
  newtSetSuspendCallback(rb_ext_Screen_suspend_callback_function, (void *) cb);
  return Qnil;
}

static VALUE rb_ext_Screen_HelpCallback(VALUE self, VALUE cb)
{
  INIT_GUARD();
  cb = rb_struct_new(rb_ext_sCallback, Qnil, rb_binding_new(), cb, Qnil, NULL);
  rb_obj_freeze(cb);
  rb_cvar_set(self, CVAR_HELP_CALLBACK, cb);
  newtSetHelpCallback(rb_ext_Screen_help_callback_function);
  return Qnil;
}

static VALUE rb_ext_Widget_callback(int argc, VALUE *argv, VALUE self)
{
  newtComponent co;
  VALUE cb, data = Qnil;

  if (argc < 1 || argc > 2)
    ARG_ERROR(argc, "1 or 2");

  INIT_GUARD();
  if (argc == 2)
    data = argv[1];

  Get_newtComponent(self, co);
  cb = rb_struct_new(rb_ext_sCallback, self, rb_binding_new(), argv[0], data, NULL);
  rb_obj_freeze(cb);
  rb_ivar_set(self, IVAR_WIDGET_CALLBACK, cb);
  newtComponentAddCallback(co, rb_ext_Widget_callback_function, (void *) cb);
  return Qnil;
}

static VALUE rb_ext_Widget_takesFocus(VALUE self, VALUE index)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtComponentTakesFocus(co, NUM2INT(index));
  return Qnil;
}

static VALUE rb_ext_Widget_GetPosition(VALUE self)
{
  newtComponent co;
  int left, top;

  Get_newtComponent(self, co);
  newtComponentGetPosition(co, &left, &top);
  return rb_ary_new_from_args(2, INT2NUM(left), INT2NUM(top));
}

static VALUE rb_ext_Widget_GetSize(VALUE self)
{
  newtComponent co;
  int width, height;

  Get_newtComponent(self, co);
  newtComponentGetSize(co, &width, &height);
  return rb_ary_new_from_args(2, INT2NUM(width), INT2NUM(height));
}

static VALUE rb_ext_Widget_equal(VALUE self, VALUE obj)
{
  newtComponent co, cco;
  void *data;

  if (NIL_P(obj)) return Qfalse;
  if (self == obj) return Qtrue;

  if (rb_obj_is_kind_of(obj, cWidget) || rb_obj_is_kind_of(obj, cExitStruct)) {
    Get_Widget_Data(self, data);
    co = ((Widget_data *) data)->co;
    if (rb_obj_is_kind_of(obj, cExitStruct)) {
      Data_Get_Struct(obj, rb_newt_ExitStruct, data);
      if (co == (((rb_newt_ExitStruct *) data)->es.u.co))
        return Qtrue;
    } else {
      Get_Widget_Data(obj, data);
      cco = ((Widget_data *) data)->co;
      if (co == cco) return Qtrue;
    }
  }
  return Qfalse;
}

static VALUE rb_ext_Widget_inspect(VALUE self)
{
  newtComponent co;
  void *data;

  VALUE classname = rb_class_name(rb_obj_class(self));
  char *class = StringValuePtr(classname);

  Get_Widget_Data(self, data);
  co = ((Widget_data *) data)->co;
  return rb_sprintf("#<%s:%p component=%p>", class, (void *) self, co);
}

static VALUE rb_ext_ExitStruct_reason(VALUE self)
{
  rb_newt_ExitStruct *rb_es;

  Data_Get_Struct(self, rb_newt_ExitStruct, rb_es);
  return INT2NUM(rb_es->es.reason);
}

static VALUE rb_ext_ExitStruct_watch(VALUE self)
{
  rb_newt_ExitStruct *rb_es;

  Data_Get_Struct(self, rb_newt_ExitStruct, rb_es);
  if (rb_es->es.reason == NEWT_EXIT_FDREADY)
    return INT2NUM(rb_es->es.u.watch);
  else
    return Qnil;
}

static VALUE rb_ext_ExitStruct_key(VALUE self)
{
  rb_newt_ExitStruct *rb_es;

  Data_Get_Struct(self, rb_newt_ExitStruct, rb_es);
  if (rb_es->es.reason == NEWT_EXIT_HOTKEY)
    return INT2NUM(rb_es->es.u.key);
  else
    return Qnil;
}

static VALUE rb_ext_ExitStruct_component(VALUE self)
{
  rb_newt_ExitStruct *rb_es;

  Data_Get_Struct(self, rb_newt_ExitStruct, rb_es);
  if (rb_es->es.reason == NEWT_EXIT_COMPONENT) {
      return rb_hash_aref(rb_es->components, PTR2NUM(rb_es->es.u.co));
  } else {
      return Qnil;
  }
}

static VALUE rb_ext_ExitStruct_equal(VALUE self, VALUE obj)
{
  rb_newt_ExitStruct *rb_es;
  newtComponent co;
  void *data;

  if (NIL_P(obj)) return Qfalse;
  if (self == obj) return Qtrue;

  /* Compare components for backwards compatibility with newtRunForm(). */
  if (rb_obj_is_kind_of(obj, cWidget)) {
    Data_Get_Struct(self, rb_newt_ExitStruct, rb_es);
    Get_Widget_Data(obj, data);
    co = ((Widget_data *) data)->co;
    if (rb_es->es.reason == NEWT_EXIT_COMPONENT
        && rb_es->es.u.co == co) return Qtrue;
  }
  return Qfalse;
}

static VALUE rb_ext_ExitStruct_inspect(VALUE self)
{
  rb_newt_ExitStruct *rb_es;
  VALUE classname = rb_class_name(rb_obj_class(self));
  char *class = StringValuePtr(classname);

  Data_Get_Struct(self, rb_newt_ExitStruct, rb_es);
  switch(rb_es->es.reason) {
    case NEWT_EXIT_HOTKEY:
      return rb_sprintf("#<%s:%p reason=%d, key=%d>", class, (void *) self,
                        rb_es->es.reason, rb_es->es.u.key);
    case NEWT_EXIT_COMPONENT:
      return rb_sprintf("#<%s:%p reason=%d, component=%p>", class, (void *) self,
                        rb_es->es.reason, rb_es->es.u.co);
    case NEWT_EXIT_FDREADY:
      return rb_sprintf("#<%s:%p reason=%d, watch=%d>", class, (void *) self,
                        rb_es->es.reason, rb_es->es.u.watch);
    case NEWT_EXIT_TIMER:
    case NEWT_EXIT_ERROR:
      return rb_sprintf("#<%s:%p reason=%d>", class, (void *) self,
                        rb_es->es.reason);
    default:
      return rb_call_super(0, NULL);
  }
}

static VALUE rb_ext_Label_new(VALUE self, VALUE left, VALUE top, VALUE text)
{
  newtComponent co;

  INIT_GUARD();
  co = newtLabel(NUM2INT(left), NUM2INT(top), StringValuePtr(text));
  return Make_Widget(self, co);
}

static VALUE rb_ext_Label_SetText(VALUE self, VALUE text)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtLabelSetText(co, StringValuePtr(text));
  return Qnil;
}

static VALUE rb_ext_Label_SetColors(VALUE self, VALUE colorset)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtLabelSetColors(co, NUM2INT(colorset));
  return Qnil;
}

static VALUE rb_ext_CompactButton_new(VALUE self, VALUE left, VALUE top, VALUE text)
{
  newtComponent co;

  INIT_GUARD();
  co = newtCompactButton(NUM2INT(left), NUM2INT(top), StringValuePtr(text));
  return Make_Widget(self, co);
}

static VALUE rb_ext_Button_new(VALUE self, VALUE left, VALUE top, VALUE text)
{
  newtComponent co;

  INIT_GUARD();
  co = newtButton(NUM2INT(left), NUM2INT(top), StringValuePtr(text));
  return Make_Widget(self, co);
}

static VALUE rb_ext_Checkbox_new(int argc, VALUE *argv, VALUE self)
{
  newtComponent co;
  const char *seq = NULL;
  char defValue = 0;

  if (argc < 3 || argc > 5)
    ARG_ERROR(argc, "3..5");

  INIT_GUARD();
  if (argc > 3 && !NIL_P(argv[3]))
    defValue = StringValuePtr(argv[3])[0];

  if (argc == 5 && !NIL_P(argv[4]) && RSTRING_LEN(argv[4]) > 0)
    seq = StringValuePtr(argv[4]);

  co = newtCheckbox(NUM2INT(argv[0]), NUM2INT(argv[1]), StringValuePtr(argv[2]), defValue, seq, NULL);
  return Make_Widget(self, co);
}

static VALUE rb_ext_Checkbox_GetValue(VALUE self)
{
  newtComponent co;
  char value[2];

  Get_newtComponent(self, co);
  value[0] = newtCheckboxGetValue(co);
  value[1] = '\0';
  return rb_str_new2(value);
}

static VALUE rb_ext_Checkbox_SetValue(VALUE self, VALUE value)
{
  newtComponent co;

  Get_newtComponent(self, co);
  if (RSTRING_LEN(value) > 0) {
    newtCheckboxSetValue(co, StringValuePtr(value)[0]);
  }
  return Qnil;
}

static VALUE rb_ext_Checkbox_SetFlags(int argc, VALUE *argv, VALUE self)
{
  newtComponent co;
  int sense = NEWT_FLAGS_SET;

  if (argc < 1 || argc > 2)
    ARG_ERROR(argc, "1..2");

  if (argc == 2)
    sense = NUM2INT(argv[1]);

  Get_newtComponent(self, co);
  newtCheckboxSetFlags(co, NUM2INT(argv[0]), sense);
  return Qnil;
}

static VALUE rb_ext_RadioButton_new(int argc, VALUE *argv, VALUE self)
{
  newtComponent co, cco = NULL;
  int is_default = 0;

  if (argc < 3 || argc > 5)
    ARG_ERROR(argc, "3..5");

  INIT_GUARD();
  if (argc >= 4)
    is_default = NUM2INT(argv[3]);

  if (argc == 5 && argv[4] != Qnil)
    Get_newtComponent(argv[4], cco);

  co = newtRadiobutton(NUM2INT(argv[0]), NUM2INT(argv[1]), StringValuePtr(argv[2]), is_default, cco);
  return Make_Widget(self, co);
}

static VALUE rb_ext_RadioButton_GetCurrent(VALUE self)
{
  newtComponent co, cco;

  Get_newtComponent(self, co);
  cco = newtRadioGetCurrent(co);
  return Make_Widget_Ref(cRadioButton, cco);
}

static VALUE rb_ext_RadioButton_SetCurrent(VALUE self)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtRadioSetCurrent(co);
  return Qnil;
}

static VALUE rb_ext_Listbox_new(int argc, VALUE *argv, VALUE self)
{
  newtComponent co;
  int flags;

  if (argc < 3 || argc > 4)
    ARG_ERROR(argc, "3..4");

  INIT_GUARD();
  flags = (argc == 4) ? NUM2INT(argv[3]) : 0;

  co = newtListbox(NUM2INT(argv[0]), NUM2INT(argv[1]), NUM2INT(argv[2]), flags);
  return Make_Widget(self, co);
}

static VALUE rb_ext_Listbox_GetCurrent(VALUE self)
{
  newtComponent co;

  Get_newtComponent(self, co);
  return (VALUE) newtListboxGetCurrent(co);
}

static VALUE rb_ext_Listbox_SetCurrent(VALUE self, VALUE num)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtListboxSetCurrent(co, NUM2INT(num));
  return Qnil;
}

static VALUE rb_ext_Listbox_SetCurrentByKey(VALUE self, VALUE key)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtListboxSetCurrentByKey(co, (void *) key);
  return Qnil;
}

static VALUE rb_ext_Listbox_GetEntry(VALUE self, VALUE num)
{
  char *text; void *data;
  newtComponent co;

  Get_newtComponent(self, co);
  newtListboxGetEntry(co, NUM2INT(num), &text, &data);
  return rb_ary_new_from_args(2, rb_str_new2(text), (VALUE *) data);
}

static VALUE rb_ext_Listbox_SetEntry(VALUE self, VALUE num, VALUE text)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtListboxSetEntry(co, NUM2INT(num), StringValuePtr(text));
  return Qnil;
}

static VALUE rb_ext_Listbox_SetWidth(VALUE self, VALUE width)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtListboxSetWidth(co, NUM2INT(width));
  return Qnil;
}

static VALUE rb_ext_Listbox_SetData(VALUE self, VALUE num, VALUE data)
{
  newtComponent co;

  Get_newtComponent(self, co);
  Data_Attach(self, data);
  newtListboxSetData(co, NUM2INT(num), (void *) data);
  return Qnil;
}

static VALUE rb_ext_Listbox_AppendEntry(VALUE self, VALUE text, VALUE data)
{
  newtComponent co;

  Get_newtComponent(self, co);
  Data_Attach(self, data);
  newtListboxAppendEntry(co, StringValuePtr(text), (void *) data);
  return Qnil;
}

static VALUE rb_ext_Listbox_InsertEntry(VALUE self, VALUE text, VALUE data, VALUE key)
{
  newtComponent co;

  Get_newtComponent(self, co);
  Data_Attach(self, data);
  newtListboxInsertEntry(co, StringValuePtr(text), (void *) data, (void *) key);
  return Qnil;
}

static VALUE rb_ext_Listbox_DeleteEntry(VALUE self, VALUE data)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtListboxDeleteEntry(co, (void *) data);
  return Qnil;
}

static VALUE rb_ext_Listbox_Clear(VALUE self)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtListboxClear(co);
  return Qnil;
}

static VALUE rb_ext_Listbox_GetSelection(VALUE self)
{
  newtComponent co;
  VALUE ary, item;
  void **items;
  int i, numitems = 0;

  Get_newtComponent(self, co);
  items = newtListboxGetSelection(co, &numitems);
  ary = rb_ary_new();
  for (i = 0; i < numitems; i++) {
      item = (VALUE) items[i];
      rb_ary_push(ary, item);
  }
  return ary;
}

static VALUE rb_ext_Listbox_ClearSelection(VALUE self)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtListboxClearSelection(co);
  return Qnil;
}

static VALUE rb_ext_Listbox_SelectItem(VALUE self, VALUE key, VALUE sense)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtListboxSelectItem(co, (void *) key, NUM2INT(sense));
  return Qnil;
}

static VALUE rb_ext_Listbox_ItemCount(VALUE self)
{
  newtComponent co;

  Get_newtComponent(self, co);
  return INT2NUM(newtListboxItemCount(co));
}

static VALUE checkboxtree_collect_selection(int numitems, VALUE *data)
{
  VALUE ary;
  int i;

  ary = Qnil;
  if (numitems > 0) {
    ary = rb_ary_new();
    for (i = 0; i < numitems; i++)
      rb_ary_push(ary, data[i]);
  }
  return ary;
}

static VALUE rb_ext_CheckboxTree_new(int argc, VALUE *argv, VALUE self)
{
  newtComponent co;
  int flags;

  if (argc < 3 || argc > 4)
    ARG_ERROR(argc, "3..4");

  INIT_GUARD();
  flags = (argc == 4) ? NUM2INT(argv[3]) : 0;

  co = newtCheckboxTree(NUM2INT(argv[0]), NUM2INT(argv[1]), NUM2INT(argv[2]), flags);
  return Make_Widget(self, co);
}

static VALUE rb_ext_CheckboxTree_AddItem(VALUE self, VALUE args)
{
  newtComponent co;
  int *indexes;
  char *text; VALUE data;
  int i, len, flags;

  len = RARRAY_LENINT(args);
  if (len < 4)
    ARG_ERROR(len, "4+");

  Get_newtComponent(self, co);
  indexes = ALLOCA_N(int, (len - 4) + 2);
  for (i = 0; i < (len - 4) + 1; i++)
    indexes[i] = NUM2INT(RARRAY_PTR(args)[i+3]);
  indexes[(len - 4) + 1] = NEWT_ARG_LAST;

  text = StringValuePtr(RARRAY_PTR(args)[0]);
  data = RARRAY_PTR(args)[1];
  flags = NUM2INT(RARRAY_PTR(args)[2]);
  Data_Attach(self, data);
  newtCheckboxTreeAddArray(co, text, (void *) data, flags, indexes);
  return Qnil;
}

static VALUE rb_ext_CheckboxTree_GetSelection(VALUE self)
{
  newtComponent co;
  VALUE *data;
  int numitems;

  Get_newtComponent(self, co);
  data = (VALUE *) newtCheckboxTreeGetSelection(co, &numitems);
  return checkboxtree_collect_selection(numitems, data);
}

static VALUE rb_ext_CheckboxTree_GetCurrent(VALUE self)
{
  newtComponent co;

  Get_newtComponent(self, co);
  return (VALUE) newtCheckboxTreeGetCurrent(co);
}

static VALUE rb_ext_CheckboxTree_SetCurrent(VALUE self, VALUE data)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtCheckboxTreeSetCurrent(co, (void *) data);
  return Qnil;
}

static VALUE rb_ext_CheckboxTree_FindItem(VALUE self, VALUE data)
{
  newtComponent co;
  int *path;
  VALUE ary;
  int i;

  ary = Qnil;
  Get_newtComponent(self, co);
  path = newtCheckboxTreeFindItem(co, (void *) data);
  if (path != NULL) {
    ary = rb_ary_new();
    for (i = 0; path[i] != NEWT_ARG_LAST; i++)
      rb_ary_push(ary, INT2NUM(path[i]));
  }
  return ary;
}

static VALUE rb_ext_CheckboxTree_SetEntry(VALUE self, VALUE data, VALUE text)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtCheckboxTreeSetEntry(co, (void *) data, StringValuePtr(text));
  return Qnil;
}

static VALUE rb_ext_CheckboxTree_SetWidth(VALUE self, VALUE width)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtCheckboxTreeSetWidth(co, NUM2INT(width));
  return Qnil;
}

static VALUE rb_ext_CheckboxTree_GetEntryValue(VALUE self, VALUE data)
{
  newtComponent co;
  char value[2];

  Get_newtComponent(self, co);
  value[0] = newtCheckboxTreeGetEntryValue(co, (void *) data);
  value[1] = '\0';
  return (value[0] == -1) ? Qnil : rb_str_new_cstr(value);
}

static VALUE rb_ext_CheckboxTree_SetEntryValue(VALUE self, VALUE data, VALUE value) {
  newtComponent co;

  Get_newtComponent(self, co);
  newtCheckboxTreeSetEntryValue(co, (void *) data, StringValueCStr(value)[0]);
  return Qnil;
}

static VALUE rb_ext_CheckboxTreeMulti_new(int argc, VALUE *argv, VALUE self)
{
  newtComponent co;
  char *seq;
  int flags;

  if (argc < 3 || argc > 5)
    ARG_ERROR(argc, "3..5");

  INIT_GUARD();
  seq = NULL;
  if (argc >= 4 && !NIL_P(argv[3]) && RSTRING_LEN(argv[3]))
    seq = StringValuePtr(argv[3]);

  flags = (argc == 5) ? NUM2INT(argv[4]) : 0;

  co = newtCheckboxTreeMulti(NUM2INT(argv[0]), NUM2INT(argv[1]), NUM2INT(argv[2]), seq, flags);
  return Make_Widget(self, co);
}

static VALUE rb_ext_CheckboxTreeMulti_GetSelection(VALUE self, VALUE seqnum)
{
  newtComponent co;
  VALUE *data;
  int numitems;

  Get_newtComponent(self, co);
  data = (VALUE *) newtCheckboxTreeGetMultiSelection(co, &numitems, StringValuePtr(seqnum)[0]);
  return checkboxtree_collect_selection(numitems, data);
}

static VALUE rb_ext_Textbox_new(int argc, VALUE *argv, VALUE self)
{
  newtComponent co;
  int flags;

  if (argc < 4 || argc > 5)
    ARG_ERROR(argc, "4..5");

  INIT_GUARD();
  flags = (argc == 5) ? NUM2INT(argv[4]) : 0;

  co = newtTextbox(NUM2INT(argv[0]), NUM2INT(argv[1]), NUM2INT(argv[2]), NUM2INT(argv[3]), flags);
  return Make_Widget(self, co);
}

static VALUE rb_ext_Textbox_SetText(VALUE self, VALUE text)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtTextboxSetText(co, StringValuePtr(text));
  return Qnil;
}

static VALUE rb_ext_Textbox_SetHeight(VALUE self, VALUE height)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtTextboxSetHeight(co, NUM2INT(height));
  return Qnil;
}

static VALUE rb_ext_Textbox_GetNumLines(VALUE self)
{
  newtComponent co;

  Get_newtComponent(self, co);
  return INT2NUM(newtTextboxGetNumLines(co));
}

static VALUE rb_ext_Textbox_SetColors(VALUE self, VALUE normal, VALUE active)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtTextboxSetColors(co, NUM2INT(normal), NUM2INT(active));
  return Qnil;
}

static VALUE rb_ext_TextboxReflowed_new(int argc, VALUE *argv, VALUE self)
{
  newtComponent co;
  int flags;

  if (argc < 6 || argc > 7)
    ARG_ERROR(argc, "6..7");

  INIT_GUARD();
  flags = (argc == 7) ? NUM2INT(argv[6]) : 0;

  co = newtTextboxReflowed(NUM2INT(argv[0]), NUM2INT(argv[1]),
                           StringValuePtr(argv[2]), NUM2INT(argv[3]),
                           NUM2INT(argv[4]), NUM2INT(argv[5]), flags);

  return Make_Widget(self, co);
}

static VALUE rb_ext_Form_new(int argc, VALUE *argv, VALUE self)
{
  newtComponent co;
  VALUE helpTag;
  int flags = 0;

  if (argc > 3)
    ARG_ERROR(argc, "0..3");

  INIT_GUARD();
  helpTag = (argc >= 2) ? argv[1] : Qnil;
  flags = (argc == 3) ? NUM2INT(argv[2]) : 0;

  /* Can't determine how Form scrollbars work, so just pass NULL. */
  co = newtForm(NULL, (void *) helpTag, flags);
  return Make_Widget(self, co);
}

static VALUE rb_ext_Form_SetBackground(VALUE self, VALUE color)
{
  newtComponent form;

  Get_newtComponent(self, form);
  newtFormSetBackground(form, NUM2INT(color));
  return Qnil;
}

static VALUE rb_ext_Form_AddComponents(VALUE self, VALUE components)
{
  Widget_data *form, *co;
  VALUE str;
  int i;

  INIT_GUARD();
  Get_Widget_Data(self, form);
  if (RARRAY_LEN(components) > 0 && form->components == Qnil) {
    form->components = rb_hash_new();
    rb_gc_register_address(&form->components);
  }

  for (i = 0; i < RARRAY_LEN(components); i++) {
    Get_Widget_Data(RARRAY_PTR(components)[i], co);
    if (co->flags & FLAG_ADDED_TO_FORM) {
      str = rb_inspect(RARRAY_PTR(components)[i]);
      rb_raise(rb_eRuntimeError, "%s is already added to a Form",
               StringValuePtr(str));
    }

    co->flags ^= FLAG_GC_FREE;
    co->flags |= FLAG_ADDED_TO_FORM;
    rb_hash_aset(form->components, PTR2NUM(co->co), RARRAY_PTR(components)[i]);
    newtFormAddComponent(form->co, co->co);
  }
  return Qnil;
}

static VALUE rb_ext_Form_SetSize(VALUE self)
{
  newtComponent form;

  Get_newtComponent(self, form);
  newtFormSetSize(form);
  return Qnil;
}

static VALUE rb_ext_Form_SetCurrent(VALUE self, VALUE obj)
{
  newtComponent form, co;

  Get_newtComponent(self, form);
  Get_newtComponent(obj, co);
  newtFormSetCurrent(form, co);
  return Qnil;
}

static VALUE rb_ext_Form_GetCurrent(VALUE self)
{
  newtComponent form, co;

  Get_newtComponent(self, form);
  co = newtFormGetCurrent(form);
  return Make_Widget_Ref(cWidget, co);
}

static VALUE rb_ext_Form_SetHeight(VALUE self, VALUE height)
{
  newtComponent form;

  Get_newtComponent(self, form);
  newtFormSetHeight(form, NUM2INT(height));
  return Qnil;
}

static VALUE rb_ext_Form_SetWidth(VALUE self, VALUE width)
{
  newtComponent form;

  Get_newtComponent(self, form);
  newtFormSetWidth(form, NUM2INT(width));
  return Qnil;
}

static VALUE rb_ext_Form_Run(VALUE self)
{
  Widget_data *data;
  rb_newt_ExitStruct *rb_es;

  INIT_GUARD();
  Get_Widget_Data(self, data);
  rb_es = ALLOC(rb_newt_ExitStruct);
  newtFormRun(data->co, &rb_es->es);
  rb_es->components = data->components;
  rb_gc_register_address(&rb_es->components);
  return Data_Wrap_Struct(cExitStruct, 0, rb_newt_es_free, rb_es);
}

static VALUE rb_ext_Form_DrawForm(VALUE self)
{
  newtComponent form;

  Get_newtComponent(self, form);
  newtDrawForm(form);
  return Qnil;
}

static VALUE rb_ext_Form_AddHotKey(VALUE self, VALUE key)
{
  newtComponent form;

  Get_newtComponent(self, form);
  newtFormAddHotKey(form, NUM2INT(key));
  return Qnil;
}

static VALUE rb_ext_Form_SetTimer(VALUE self, VALUE millisecs)
{
  newtComponent form;

  Get_newtComponent(self, form);
  newtFormSetTimer(form, NUM2INT(millisecs));
  return Qnil;
}

static VALUE rb_ext_Form_WatchFd(VALUE self, VALUE io, VALUE flags)
{
  newtComponent form;
  int fd;

  if (!rb_obj_is_kind_of(io, rb_cIO) && TYPE(io) != T_FIXNUM)
    rb_raise(rb_eTypeError, "neither IO nor file descriptor");

  Get_newtComponent(self, form);
  fd = NUM2INT(rb_funcall(io, rb_intern("fileno"), 0));
  newtFormWatchFd(form, fd, NUM2INT(flags));
  return Qnil;
}

static VALUE rb_ext_Entry_new(int argc, VALUE *argv, VALUE self)
{
  newtComponent co;
  int flags;

  if (argc < 4 || argc > 5)
    ARG_ERROR(argc, "4..5");

  INIT_GUARD();
  flags = (argc == 5) ? NUM2INT(argv[4]) : 0;

  co = newtEntry(NUM2INT(argv[0]), NUM2INT(argv[1]), StringValuePtr(argv[2]),
                 NUM2INT(argv[3]), NULL, flags);

  return Make_Widget(self, co);
}

static VALUE rb_ext_Entry_Set(VALUE self, VALUE value, VALUE cursorAtEnd)
{
  newtComponent co;

  Get_newtComponent(self, co);
  switch(TYPE(cursorAtEnd)) {
    case T_TRUE:
      newtEntrySet(co, StringValuePtr(value), 1);
      break;
    case T_FALSE:
      newtEntrySet(co, StringValuePtr(value), 0);
      break;
    case T_FIXNUM:
      newtEntrySet(co, StringValuePtr(value), NUM2INT(cursorAtEnd));
      break;
    default:
      rb_raise(rb_eTypeError, "Boolean or Fixnum expected");
      break;
  }
  return Qnil;
}

static VALUE rb_ext_Entry_GetValue(VALUE self)
{
  newtComponent co;

  Get_newtComponent(self, co);
  return rb_str_new2(newtEntryGetValue(co));
}

static VALUE rb_ext_Entry_SetFilter(int argc, VALUE *argv, VALUE self)
{
  newtComponent co;
  VALUE cb, data = Qnil;

  if (argc < 1 || argc > 2)
    ARG_ERROR(argc, "1 or 2");

  if (argc == 2)
    data = argv[1];

  Get_newtComponent(self, co);
  cb = rb_struct_new(rb_ext_sCallback, self, rb_binding_new(), argv[0], data, NULL);
  rb_obj_freeze(cb);
  rb_ivar_set(self, IVAR_FILTER_CALLBACK, cb);
  newtEntrySetFilter(co, rb_ext_Entry_filter_function, (void *) cb);
  return Qnil;
}

static VALUE rb_ext_Entry_SetFlags(int argc, VALUE *argv, VALUE self)
{
  newtComponent co;
  int sense = NEWT_FLAGS_SET;

  if (argc < 1 || argc > 2)
    ARG_ERROR(argc, "1..2");

  if (argc == 2)
    sense = NUM2INT(argv[1]);

  Get_newtComponent(self, co);
  newtEntrySetFlags(co, NUM2INT(argv[0]), sense);
  return Qnil;
}

static VALUE rb_ext_Entry_SetColors(VALUE self, VALUE normal, VALUE disabled)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtEntrySetColors(co, NUM2INT(normal), NUM2INT(disabled));
  return Qnil;
}

static VALUE rb_ext_Entry_GetCursorPosition(VALUE self)
{
  newtComponent co;

  Get_newtComponent(self, co);
  return INT2NUM(newtEntryGetCursorPosition(co));
}

static VALUE rb_ext_Entry_SetCursorPosition(VALUE self, VALUE position)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtEntrySetCursorPosition(co, NUM2INT(position));
  return Qnil;
}

static VALUE rb_ext_Scale_new(VALUE self, VALUE left, VALUE top, VALUE width, VALUE fullValue)
{
  newtComponent co;

  INIT_GUARD();
  co = newtScale(NUM2INT(left), NUM2INT(top), NUM2INT(width), NUM2INT(fullValue));
  return Make_Widget(self, co);
}

static VALUE rb_ext_Scale_Set(VALUE self, VALUE amount)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtScaleSet(co, NUM2INT(amount));
  return Qnil;
}

static VALUE rb_ext_Scale_SetColors(VALUE self, VALUE empty, VALUE full)
{
  newtComponent co;

  Get_newtComponent(self, co);
  newtScaleSetColors(co, NUM2INT(empty), NUM2INT(full));
  return Qnil;
}

static VALUE rb_ext_Grid_new(VALUE self, VALUE cols, VALUE rows)
{
  newtGrid grid;
  VALUE widget;
  int num_cols, num_rows;

  num_cols = NUM2INT(cols);
  num_rows = NUM2INT(rows);

  if (num_cols <= 0 || num_rows <= 0)
    rb_raise(rb_eRuntimeError, "specified number of columns or rows should be greater than 0");

  INIT_GUARD();
  grid = newtCreateGrid(num_cols, num_rows);
  widget = Data_Wrap_Struct(self, 0, 0, grid);
  rb_ivar_set(widget, IVAR_COLS, cols);
  rb_ivar_set(widget, IVAR_ROWS, rows);
  return widget;
}

static VALUE rb_ext_Grid_SetField(VALUE self, VALUE col, VALUE row, VALUE type, VALUE val,
    VALUE padLeft, VALUE padTop, VALUE padRight, VALUE padBottom, VALUE anchor, VALUE flags)
{
  newtGrid grid;
  void *co;
  int icol, irow, itype, cols, rows;

  icol = NUM2INT(col);
  irow = NUM2INT(row);
  itype = NUM2INT(type);

  cols = NUM2INT(rb_ivar_get(self, IVAR_COLS));
  rows = NUM2INT(rb_ivar_get(self, IVAR_ROWS));
  if (icol >= cols || irow >= rows)
    rb_raise(rb_eRuntimeError, "attempting to set a field at an invalid position (%d, %d)", icol, irow);

  INIT_GUARD();
  if (itype == NEWT_GRID_SUBGRID) {
    Data_Get_Struct(val, struct grid_s, co);
  } else {
    Get_Widget_Data(val, co);
    co = ((Widget_data *) co)->co;
  }

  Data_Get_Struct(self, struct grid_s, grid);
  newtGridSetField(grid, icol, irow, itype, co, NUM2INT(padLeft),
                   NUM2INT(padTop), NUM2INT(padRight), NUM2INT(padBottom),
                   NUM2INT(anchor), NUM2INT(flags));

  return Qnil;
}

static VALUE rb_ext_Grid_WrappedWindow(int argc, VALUE *argv, VALUE self)
{
  newtGrid grid;
  char *title;

  if (argc != 1 && argc != 3)
    ARG_ERROR(argc, "1 or 3");

  INIT_GUARD();
  title = StringValuePtr(argv[0]);
  Data_Get_Struct(self, struct grid_s, grid);
  if (argc == 1) {
    newtGridWrappedWindow(grid, title);
  } else if (argc == 3) {
    newtGridWrappedWindowAt(grid, title, NUM2INT(argv[1]), NUM2INT(argv[2]));
  }
  return Qnil;
}

static VALUE rb_ext_Grid_GetSize(VALUE self)
{
  newtGrid grid;
  int width, height;

  INIT_GUARD();
  Data_Get_Struct(self, struct grid_s, grid);
  newtGridGetSize(grid, &width, &height);
  return rb_ary_new_from_args(2, INT2NUM(width), INT2NUM(height));
}

void Init_ruby_newt(){
  mNewt = rb_define_module("Newt");
  rb_define_module_function(mNewt, "init", rb_ext_Screen_Init, 0);
  rb_define_module_function(mNewt, "finish", rb_ext_Screen_Finished, 0);
  rb_define_module_function(mNewt, "delay", rb_ext_Delay, 1);
  rb_define_module_function(mNewt, "reflow_text", rb_ext_ReflowText, 4);

  mScreen = rb_define_class_under(mNewt, "Screen", rb_cObject);
  rb_define_alloc_func(mScreen, newt_s_alloc);
  rb_define_module_function(mScreen, "init", rb_ext_Screen_Init, 0);
  rb_define_module_function(mScreen, "new", rb_ext_Screen_new, 0);
  rb_define_module_function(mScreen, "cls", rb_ext_Screen_Cls, 0);
  rb_define_module_function(mScreen, "finish", rb_ext_Screen_Finished, 0);
  rb_define_module_function(mScreen, "wait_for_key", rb_ext_Screen_WaitForKey, 0);
  rb_define_module_function(mScreen, "clear_keybuffer", rb_ext_Screen_ClearKeyBuffer, 0);
  rb_define_module_function(mScreen, "open_window", rb_ext_Screen_OpenWindow, 5);
  rb_define_module_function(mScreen, "centered_window", rb_ext_Screen_CenteredWindow, 3);
  rb_define_module_function(mScreen, "pop_window", rb_ext_Screen_PopWindow, 0);
  rb_define_module_function(mScreen, "set_colors", rb_ext_Screen_SetColors, 1);
  rb_define_module_function(mScreen, "set_color", rb_ext_Screen_SetColor, 3);
  rb_define_module_function(mScreen, "refresh", rb_ext_Screen_Refresh, 0);
  rb_define_module_function(mScreen, "suspend", rb_ext_Screen_Suspend, 0);
  rb_define_module_function(mScreen, "resume", rb_ext_Screen_Resume, 0);
  rb_define_module_function(mScreen, "suspend_callback", rb_ext_Screen_SuspendCallback, -1);
  rb_define_module_function(mScreen, "help_callback", rb_ext_Screen_HelpCallback, 1);
  rb_define_module_function(mScreen, "push_helpline", rb_ext_Screen_PushHelpLine, 1);
  rb_define_module_function(mScreen, "redraw_helpline", rb_ext_Screen_RedrawHelpLine, 0);
  rb_define_module_function(mScreen, "pop_helpline", rb_ext_Screen_PopHelpLine, 0);
  rb_define_module_function(mScreen, "draw_roottext", rb_ext_Screen_DrawRootText, 3);
  rb_define_module_function(mScreen, "bell", rb_ext_Screen_Bell, 0);
  rb_define_module_function(mScreen, "cursor_off", rb_ext_Screen_CursorOff, 0);
  rb_define_module_function(mScreen, "cursor_on", rb_ext_Screen_CursorOn, 0);
  rb_define_module_function(mScreen, "size", rb_ext_Screen_Size, 0);
  rb_define_module_function(mScreen, "win_message", rb_ext_Screen_WinMessage, 3);
  rb_define_module_function(mScreen, "win_choice", rb_ext_Screen_WinChoice, 4);
  rb_define_module_function(mScreen, "win_menu", rb_ext_Screen_WinMenu, -2);
  rb_define_module_function(mScreen, "win_entries", rb_ext_Screen_WinEntries, -2);

  rb_ext_sCallback = rb_struct_define("NewtCallback", "widget", "context", "callback", "data", NULL);

  cWidget = rb_define_class_under(mNewt, "Widget", rb_cObject);
  rb_define_alloc_func(cWidget, newt_s_alloc);
  rb_define_method(cWidget, "callback", rb_ext_Widget_callback, -1);
  rb_define_method(cWidget, "takes_focus", rb_ext_Widget_takesFocus, 1);
  rb_define_method(cWidget, "get_position", rb_ext_Widget_GetPosition, 0);
  rb_define_method(cWidget, "get_size", rb_ext_Widget_GetSize, 0);
  rb_define_method(cWidget, "==", rb_ext_Widget_equal, 1);
  rb_define_method(cWidget, "inspect", rb_ext_Widget_inspect, 0);

  cCompactButton = rb_define_class_under(mNewt, "CompactButton", cWidget);
  rb_define_singleton_method(cCompactButton, "new", rb_ext_CompactButton_new, 3);

  cButton = rb_define_class_under(mNewt, "Button", cWidget);
  rb_define_singleton_method(cButton, "new", rb_ext_Button_new, 3);

  cCheckbox = rb_define_class_under(mNewt, "Checkbox", cWidget);
  rb_define_singleton_method(cCheckbox, "new", rb_ext_Checkbox_new, -1);
  rb_define_method(cCheckbox, "get", rb_ext_Checkbox_GetValue, 0);
  rb_define_method(cCheckbox, "set", rb_ext_Checkbox_SetValue, 1);
  rb_define_method(cCheckbox, "set_flags", rb_ext_Checkbox_SetFlags, -1);

  cRadioButton = rb_define_class_under(mNewt, "RadioButton", cWidget);
  rb_define_singleton_method(cRadioButton, "new", rb_ext_RadioButton_new, -1);
  rb_define_method(cRadioButton, "get_current", rb_ext_RadioButton_GetCurrent, 0);
  rb_define_method(cRadioButton, "set_current", rb_ext_RadioButton_SetCurrent, 0);

  cLabel = rb_define_class_under(mNewt, "Label", cWidget);
  rb_define_singleton_method(cLabel, "new", rb_ext_Label_new, 3);
  rb_define_method(cLabel, "set_text", rb_ext_Label_SetText, 1);
  rb_define_method(cLabel, "set_colors", rb_ext_Label_SetColors, 1);

  cListbox = rb_define_class_under(mNewt, "Listbox", cWidget);
  rb_define_singleton_method(cListbox, "new", rb_ext_Listbox_new, -1);
  rb_define_method(cListbox, "get_current", rb_ext_Listbox_GetCurrent, 0);
  rb_define_method(cListbox, "set_current", rb_ext_Listbox_SetCurrent, 1);
  rb_define_method(cListbox, "set_current_by_key", rb_ext_Listbox_SetCurrentByKey, 1);
  rb_define_method(cListbox, "set_width", rb_ext_Listbox_SetWidth, 1);
  rb_define_method(cListbox, "set_data", rb_ext_Listbox_SetData, 2);
  rb_define_method(cListbox, "append", rb_ext_Listbox_AppendEntry, 2);
  rb_define_method(cListbox, "insert", rb_ext_Listbox_InsertEntry, 3);
  rb_define_method(cListbox, "get", rb_ext_Listbox_GetEntry, 1);
  rb_define_method(cListbox, "set", rb_ext_Listbox_SetEntry, 2);
  rb_define_method(cListbox, "delete", rb_ext_Listbox_DeleteEntry, 1);
  rb_define_method(cListbox, "clear", rb_ext_Listbox_Clear, 0);
  rb_define_method(cListbox, "get_selection", rb_ext_Listbox_GetSelection, 0);
  rb_define_method(cListbox, "clear_selection", rb_ext_Listbox_ClearSelection, 0);
  rb_define_method(cListbox, "select", rb_ext_Listbox_SelectItem, 2);
  rb_define_method(cListbox, "item_count", rb_ext_Listbox_ItemCount, 0);

  cCheckboxTree = rb_define_class_under(mNewt, "CheckboxTree", cWidget);
  rb_define_singleton_method(cCheckboxTree, "new", rb_ext_CheckboxTree_new, -1);
  rb_define_method(cCheckboxTree, "add", rb_ext_CheckboxTree_AddItem, -2);
  rb_define_method(cCheckboxTree, "get_selection", rb_ext_CheckboxTree_GetSelection, 0);
  rb_define_method(cCheckboxTree, "get_current", rb_ext_CheckboxTree_GetCurrent, 0);
  rb_define_method(cCheckboxTree, "set_current", rb_ext_CheckboxTree_SetCurrent, 1);
  rb_define_method(cCheckboxTree, "find", rb_ext_CheckboxTree_FindItem, 1);
  rb_define_method(cCheckboxTree, "set_entry", rb_ext_CheckboxTree_SetEntry, 2);
  rb_define_method(cCheckboxTree, "set_width", rb_ext_CheckboxTree_SetWidth, 1);
  rb_define_method(cCheckboxTree, "get", rb_ext_CheckboxTree_GetEntryValue, 1);
  rb_define_method(cCheckboxTree, "set", rb_ext_CheckboxTree_SetEntryValue, 2);

  cCheckboxTreeMulti = rb_define_class_under(mNewt, "CheckboxTreeMulti", cCheckboxTree);
  rb_define_singleton_method(cCheckboxTreeMulti, "new", rb_ext_CheckboxTreeMulti_new, -1);
  rb_define_method(cCheckboxTreeMulti, "get_selection", rb_ext_CheckboxTreeMulti_GetSelection, 1);

  cTextbox = rb_define_class_under(mNewt, "Textbox", cWidget);
  rb_define_singleton_method(cTextbox, "new", rb_ext_Textbox_new, -1);
  rb_define_method(cTextbox, "set_text", rb_ext_Textbox_SetText, 1);
  rb_define_method(cTextbox, "set_height", rb_ext_Textbox_SetHeight, 1);
  rb_define_method(cTextbox, "get_num_lines", rb_ext_Textbox_GetNumLines, 0);
  rb_define_method(cTextbox, "set_colors", rb_ext_Textbox_SetColors, 2);

  cTextboxReflowed = rb_define_class_under(mNewt, "TextboxReflowed", cTextbox);
  rb_define_singleton_method(cTextboxReflowed, "new", rb_ext_TextboxReflowed_new, -1);

  cForm = rb_define_class_under(mNewt, "Form", cWidget);
  rb_define_singleton_method(cForm, "new", rb_ext_Form_new, -1);
  rb_define_method(cForm, "set_background", rb_ext_Form_SetBackground, 1);
  rb_define_method(cForm, "add", rb_ext_Form_AddComponents, -2);
  rb_define_method(cForm, "set_size", rb_ext_Form_SetSize, 0);
  rb_define_method(cForm, "get_current", rb_ext_Form_GetCurrent, 0);
  rb_define_method(cForm, "set_current", rb_ext_Form_SetCurrent, 1);
  rb_define_method(cForm, "set_height", rb_ext_Form_SetHeight, 1);
  rb_define_method(cForm, "set_width", rb_ext_Form_SetWidth, 1);
  rb_define_method(cForm, "run", rb_ext_Form_Run, 0);
  rb_define_method(cForm, "draw", rb_ext_Form_DrawForm, 0);
  rb_define_method(cForm, "add_hotkey", rb_ext_Form_AddHotKey, 1);
  rb_define_method(cForm, "set_timer", rb_ext_Form_SetTimer, 1);
  rb_define_method(cForm, "watch_fd", rb_ext_Form_WatchFd, 2);

  cExitStruct = rb_define_class_under(cForm, "ExitStruct", rb_cObject);
  rb_define_alloc_func(cExitStruct, newt_s_alloc);
  rb_define_private_method(rb_singleton_class(cExitStruct), "new", NULL, 0);
  rb_define_method(cExitStruct, "reason", rb_ext_ExitStruct_reason, 0);
  rb_define_method(cExitStruct, "watch", rb_ext_ExitStruct_watch, 0);
  rb_define_method(cExitStruct, "key", rb_ext_ExitStruct_key, 0);
  rb_define_method(cExitStruct, "component", rb_ext_ExitStruct_component, 0);
  rb_define_method(cExitStruct, "==", rb_ext_ExitStruct_equal, 1);
  rb_define_method(cExitStruct, "inspect", rb_ext_ExitStruct_inspect, 0);

  cEntry = rb_define_class_under(mNewt, "Entry", cWidget);
  rb_define_singleton_method(cEntry, "new", rb_ext_Entry_new, -1);
  rb_define_method(cEntry, "set", rb_ext_Entry_Set, 2);
  rb_define_method(cEntry, "get", rb_ext_Entry_GetValue, 0);
  rb_define_method(cEntry, "set_filter", rb_ext_Entry_SetFilter, -1);
  rb_define_method(cEntry, "set_flags", rb_ext_Entry_SetFlags, -1);
  rb_define_method(cEntry, "set_colors", rb_ext_Entry_SetColors, 2);
  rb_define_method(cEntry, "get_cursor_position", rb_ext_Entry_GetCursorPosition, 0);
  rb_define_method(cEntry, "set_cursor_position", rb_ext_Entry_SetCursorPosition, 1);

  cScale = rb_define_class_under(mNewt, "Scale", cWidget);
  rb_define_singleton_method(cScale, "new", rb_ext_Scale_new, 4);
  rb_define_method(cScale, "set", rb_ext_Scale_Set, 1);
  rb_define_method(cScale, "set_colors", rb_ext_Scale_SetColors, 2);

  cGrid = rb_define_class_under(mNewt, "Grid", cWidget);
  rb_define_singleton_method(cGrid, "new", rb_ext_Grid_new, 2);
  rb_define_method(cGrid, "set_field", rb_ext_Grid_SetField, 10);
  rb_define_method(cGrid, "wrapped_window", rb_ext_Grid_WrappedWindow, -1);
  rb_define_method(cGrid, "get_size", rb_ext_Grid_GetSize, 0);

  rb_define_const(mNewt, "COLORSET_ROOT", INT2FIX(NEWT_COLORSET_ROOT));
  rb_define_const(mNewt, "COLORSET_BORDER", INT2FIX(NEWT_COLORSET_BORDER));
  rb_define_const(mNewt, "COLORSET_WINDOW", INT2FIX(NEWT_COLORSET_WINDOW));
  rb_define_const(mNewt, "COLORSET_SHADOW", INT2FIX(NEWT_COLORSET_SHADOW));
  rb_define_const(mNewt, "COLORSET_TITLE", INT2FIX(NEWT_COLORSET_TITLE));
  rb_define_const(mNewt, "COLORSET_BUTTON", INT2FIX(NEWT_COLORSET_BUTTON));
  rb_define_const(mNewt, "COLORSET_ACTBUTTON", INT2FIX(NEWT_COLORSET_ACTBUTTON));
  rb_define_const(mNewt, "COLORSET_CHECKBOX", INT2FIX(NEWT_COLORSET_CHECKBOX));
  rb_define_const(mNewt, "COLORSET_ACTCHECKBOX", INT2FIX(NEWT_COLORSET_ACTCHECKBOX));
  rb_define_const(mNewt, "COLORSET_ENTRY", INT2FIX(NEWT_COLORSET_ENTRY));
  rb_define_const(mNewt, "COLORSET_LABEL", INT2FIX(NEWT_COLORSET_LABEL));
  rb_define_const(mNewt, "COLORSET_LISTBOX", INT2FIX(NEWT_COLORSET_LISTBOX));
  rb_define_const(mNewt, "COLORSET_ACTLISTBOX", INT2FIX(NEWT_COLORSET_ACTLISTBOX));
  rb_define_const(mNewt, "COLORSET_TEXTBOX", INT2FIX(NEWT_COLORSET_TEXTBOX));
  rb_define_const(mNewt, "COLORSET_ACTTEXTBOX", INT2FIX(NEWT_COLORSET_ACTTEXTBOX));
  rb_define_const(mNewt, "COLORSET_HELPLINE", INT2FIX(NEWT_COLORSET_HELPLINE));
  rb_define_const(mNewt, "COLORSET_ROOTTEXT", INT2FIX(NEWT_COLORSET_ROOTTEXT));
  rb_define_const(mNewt, "COLORSET_EMPTYSCALE", INT2FIX(NEWT_COLORSET_EMPTYSCALE));
  rb_define_const(mNewt, "COLORSET_FULLSCALE", INT2FIX(NEWT_COLORSET_FULLSCALE));
  rb_define_const(mNewt, "COLORSET_DISENTRY", INT2FIX(NEWT_COLORSET_DISENTRY));
  rb_define_const(mNewt, "COLORSET_COMPACTBUTTON", INT2FIX(NEWT_COLORSET_COMPACTBUTTON));
  rb_define_const(mNewt, "COLORSET_ACTSELLISTBOX", INT2FIX(NEWT_COLORSET_ACTSELLISTBOX));
  rb_define_const(mNewt, "COLORSET_SELLISTBOX", INT2FIX(NEWT_COLORSET_SELLISTBOX));
  rb_define_module_function(mNewt, "COLORSET_CUSTOM", rb_ext_ColorSetCustom, 1);

  rb_define_const(mNewt, "ARG_APPEND", INT2FIX(NEWT_ARG_APPEND));

  rb_define_const(mNewt, "FLAGS_SET", INT2FIX(NEWT_FLAGS_SET));
  rb_define_const(mNewt, "FLAGS_RESET", INT2FIX(NEWT_FLAGS_RESET));
  rb_define_const(mNewt, "FLAGS_TOGGLE", INT2FIX(NEWT_FLAGS_TOGGLE));

  rb_define_const(mNewt, "FLAG_RETURNEXIT", INT2FIX(NEWT_FLAG_RETURNEXIT));
  rb_define_const(mNewt, "FLAG_HIDDEN", INT2FIX(NEWT_FLAG_HIDDEN));
  rb_define_const(mNewt, "FLAG_SCROLL", INT2FIX(NEWT_FLAG_SCROLL));
  rb_define_const(mNewt, "FLAG_DISABLED", INT2FIX(NEWT_FLAG_DISABLED));
  rb_define_const(mNewt, "FLAG_BORDER", INT2FIX(NEWT_FLAG_BORDER));
  rb_define_const(mNewt, "FLAG_WRAP", INT2FIX(NEWT_FLAG_WRAP));
  rb_define_const(mNewt, "FLAG_NOF12", INT2FIX(NEWT_FLAG_NOF12));
  rb_define_const(mNewt, "FLAG_MULTIPLE", INT2FIX(NEWT_FLAG_MULTIPLE));
  rb_define_const(mNewt, "FLAG_SELECTED", INT2FIX(NEWT_FLAG_SELECTED));
  rb_define_const(mNewt, "FLAG_CHECKBOX", INT2FIX(NEWT_FLAG_CHECKBOX));
  rb_define_const(mNewt, "FLAG_PASSWORD", INT2FIX(NEWT_FLAG_PASSWORD));
  rb_define_const(mNewt, "FLAG_SHOWCURSOR", INT2FIX(NEWT_FLAG_SHOWCURSOR));

  rb_define_const(mNewt, "FD_READ", INT2FIX(NEWT_FD_READ));
  rb_define_const(mNewt, "FD_WRITE", INT2FIX(NEWT_FD_WRITE));
  rb_define_const(mNewt, "FD_EXCEPT", INT2FIX(NEWT_FD_EXCEPT));

  rb_define_const(mNewt, "ANCHOR_LEFT", INT2FIX(NEWT_ANCHOR_LEFT));
  rb_define_const(mNewt, "ANCHOR_RIGHT", INT2FIX(NEWT_ANCHOR_RIGHT));
  rb_define_const(mNewt, "ANCHOR_TOP", INT2FIX(NEWT_ANCHOR_TOP));
  rb_define_const(mNewt, "ANCHOR_BOTTOM", INT2FIX(NEWT_ANCHOR_BOTTOM));

  rb_define_const(mNewt, "GRID_FLAG_GROWX", INT2FIX(NEWT_GRID_FLAG_GROWX));
  rb_define_const(mNewt, "GRID_FLAG_GROWY", INT2FIX(NEWT_GRID_FLAG_GROWY));
  rb_define_const(mNewt, "GRID_EMPTY", INT2FIX(NEWT_GRID_EMPTY));
  rb_define_const(mNewt, "GRID_COMPONENT", INT2FIX(NEWT_GRID_COMPONENT));
  rb_define_const(mNewt, "GRID_SUBGRID", INT2FIX(NEWT_GRID_SUBGRID));

  rb_define_const(mNewt, "KEY_TAB", INT2FIX(NEWT_KEY_TAB));
  rb_define_const(mNewt, "KEY_ENTER", INT2FIX(NEWT_KEY_ENTER));
  rb_define_const(mNewt, "KEY_SUSPEND", INT2FIX(NEWT_KEY_SUSPEND));
  rb_define_const(mNewt, "KEY_ESCAPE", INT2FIX(NEWT_KEY_ESCAPE));
  rb_define_const(mNewt, "KEY_RETURN", INT2FIX(NEWT_KEY_RETURN));

  rb_define_const(mNewt, "KEY_UP", INT2FIX(NEWT_KEY_UP));
  rb_define_const(mNewt, "KEY_DOWN", INT2FIX(NEWT_KEY_DOWN));
  rb_define_const(mNewt, "KEY_LEFT", INT2FIX(NEWT_KEY_LEFT));
  rb_define_const(mNewt, "KEY_RIGHT", INT2FIX(NEWT_KEY_RIGHT));
  rb_define_const(mNewt, "KEY_BKSPC", INT2FIX(NEWT_KEY_BKSPC));
  rb_define_const(mNewt, "KEY_DELETE", INT2FIX(NEWT_KEY_DELETE));
  rb_define_const(mNewt, "KEY_HOME", INT2FIX(NEWT_KEY_HOME));
  rb_define_const(mNewt, "KEY_END", INT2FIX(NEWT_KEY_END));
  rb_define_const(mNewt, "KEY_UNTAB", INT2FIX(NEWT_KEY_UNTAB));
  rb_define_const(mNewt, "KEY_PGUP", INT2FIX(NEWT_KEY_PGUP));
  rb_define_const(mNewt, "KEY_PGDN", INT2FIX(NEWT_KEY_PGDN));
  rb_define_const(mNewt, "KEY_INSERT", INT2FIX(NEWT_KEY_INSERT));

  rb_define_const(mNewt, "KEY_F1", INT2FIX(NEWT_KEY_F1));
  rb_define_const(mNewt, "KEY_F2", INT2FIX(NEWT_KEY_F2));
  rb_define_const(mNewt, "KEY_F3", INT2FIX(NEWT_KEY_F3));
  rb_define_const(mNewt, "KEY_F4", INT2FIX(NEWT_KEY_F4));
  rb_define_const(mNewt, "KEY_F5", INT2FIX(NEWT_KEY_F5));
  rb_define_const(mNewt, "KEY_F6", INT2FIX(NEWT_KEY_F6));
  rb_define_const(mNewt, "KEY_F7", INT2FIX(NEWT_KEY_F7));
  rb_define_const(mNewt, "KEY_F8", INT2FIX(NEWT_KEY_F8));
  rb_define_const(mNewt, "KEY_F9", INT2FIX(NEWT_KEY_F9));
  rb_define_const(mNewt, "KEY_F10", INT2FIX(NEWT_KEY_F10));
  rb_define_const(mNewt, "KEY_F11", INT2FIX(NEWT_KEY_F11));
  rb_define_const(mNewt, "KEY_F12", INT2FIX(NEWT_KEY_F12));

  rb_define_const(mNewt, "KEY_RESIZE", INT2FIX(NEWT_KEY_RESIZE));
  rb_define_const(mNewt, "KEY_ERROR", INT2FIX(NEWT_KEY_ERROR));

  rb_define_const(mNewt, "EXIT_HOTKEY", INT2FIX(NEWT_EXIT_HOTKEY));
  rb_define_const(mNewt, "EXIT_COMPONENT", INT2FIX(NEWT_EXIT_COMPONENT));
  rb_define_const(mNewt, "EXIT_FDREADY", INT2FIX(NEWT_EXIT_FDREADY));
  rb_define_const(mNewt, "EXIT_TIMER", INT2FIX(NEWT_EXIT_TIMER));
  rb_define_const(mNewt, "EXIT_ERROR", INT2FIX(NEWT_EXIT_ERROR));
}
