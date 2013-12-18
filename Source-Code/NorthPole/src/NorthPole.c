#include <pebble.h>

// Variables

static Window *window;
static TextLayer *text_layer;
static TextLayer *compass_text_layer;
static BitmapLayer *icon_layer;
static GBitmap *icon_bitmap = NULL;

static char compassValue[6];
static char compassAbbreviationValue[3];

enum AltitudeKey {
    ALTITUDE_METERS_KEY     = 0x0,      // TUPLE_CSTRING
    COMPASS_DIRECTION_KEY   = 0x1,         // TUPLE_INT
    COMPASS_DEGREES_KEY     = 0x2,         // TUPLE_INT
};

static bool displayCompassAbbreviation = true;

static AppSync sync;
static uint8_t sync_buffer[128];

static uint32_t compassBitmapId = RESOURCE_ID_IMAGE_COMPASS;


// Functions


static void sync_error_callback(DictionaryResult dict_error, AppMessageResult app_message_error, void *context) {
    APP_LOG(APP_LOG_LEVEL_DEBUG, "App Message Sync Error: %d", app_message_error);
}

static void sync_tuple_changed_callback(const uint32_t key, const Tuple* new_tuple, const Tuple* old_tuple, void* context)
{
    switch (key)
    {

        case ALTITUDE_METERS_KEY:
        {
            text_layer_set_text(text_layer, new_tuple->value->cstring);
            break;
        }
        case COMPASS_DEGREES_KEY:
        {
            strncpy(compassValue,
                    new_tuple->value->cstring,
                    sizeof(compassValue));
            
            if (!displayCompassAbbreviation)
            {
                text_layer_set_text(compass_text_layer, new_tuple->value->cstring);
            }
            
            break;
        }
        case COMPASS_DIRECTION_KEY:
        {
            strncpy(compassAbbreviationValue,
                    new_tuple->value->cstring,
                    sizeof(compassAbbreviationValue));
            
            if (displayCompassAbbreviation)
            {
                text_layer_set_text(compass_text_layer, new_tuple->value->cstring);
            }
            break;
        }
        default:
            break;
    }
}

static void select_click_handler(ClickRecognizerRef recognizer, void *context)
{
    displayCompassAbbreviation = !displayCompassAbbreviation;
    
    if (displayCompassAbbreviation)
    {
        text_layer_set_text(compass_text_layer, compassAbbreviationValue);
    }
    else
    {
        text_layer_set_text(compass_text_layer, compassValue);
    }
}

static void up_click_handler(ClickRecognizerRef recognizer, void *context)
{

}

static void down_click_handler(ClickRecognizerRef recognizer, void *context)
{
    
}

static void click_config_provider(void *context) {
  window_single_click_subscribe(BUTTON_ID_SELECT, select_click_handler);
  window_single_click_subscribe(BUTTON_ID_UP, up_click_handler);
  window_single_click_subscribe(BUTTON_ID_DOWN, down_click_handler);
}

static void window_load(Window *window)
{
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);

    
    text_layer = text_layer_create((GRect) { .origin = { 0, 14 }, .size = { bounds.size.w, 75 } });
    icon_layer = bitmap_layer_create(GRect(0, -16, 144, 168));
    compass_text_layer = text_layer_create((GRect) { .origin = { 0, 110 }, .size = { bounds.size.w, 80 } });
    
    // background properties
    icon_bitmap = gbitmap_create_with_resource(compassBitmapId);
    bitmap_layer_set_bitmap(icon_layer, icon_bitmap);
    bitmap_layer_set_background_color(icon_layer, GColorWhite);
    layer_add_child(window_layer, bitmap_layer_get_layer(icon_layer));
    
    // text properties
  text_layer_set_text_alignment(text_layer, GTextAlignmentCenter);
  text_layer_set_font(text_layer, fonts_get_system_font(FONT_KEY_ROBOTO_CONDENSED_21));
    text_layer_set_text_color(text_layer, GColorWhite);
    text_layer_set_background_color(text_layer, GColorClear);
  layer_add_child(window_layer, text_layer_get_layer(text_layer));

    // Compass Text Properties
    text_layer_set_text_alignment(compass_text_layer, GTextAlignmentCenter);
    text_layer_set_font(compass_text_layer, fonts_get_system_font(FONT_KEY_ROBOTO_CONDENSED_21));
    text_layer_set_text_color(compass_text_layer, GColorWhite);
    text_layer_set_background_color(compass_text_layer, GColorClear);
    layer_add_child(window_layer, text_layer_get_layer(compass_text_layer));


        // initial values
    Tuplet initial_values[] = {
        TupletCString(ALTITUDE_METERS_KEY, "99500m"),
        TupletCString(COMPASS_DIRECTION_KEY, "NW"),
        TupletCString(COMPASS_DEGREES_KEY, "0.0"),
    };
    
    
    app_sync_init(&sync, sync_buffer, sizeof(sync_buffer), initial_values, ARRAY_LENGTH(initial_values),
                  sync_tuple_changed_callback, sync_error_callback, NULL);
    
    
}

static void window_unload(Window *window) {
  app_sync_deinit(&sync);
  text_layer_destroy(text_layer);
}

static void init(void) {
  window = window_create();
  window_set_click_config_provider(window, click_config_provider);
  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload,
  });
    
    const int inbound_size = 128;
    const int outbound_size = 16;
    app_message_open(inbound_size, outbound_size);
    
    
  const bool animated = true;
  window_stack_push(window, animated);
}

static void deinit(void) {
  window_destroy(window);
}

int main(void) {
  init();

  APP_LOG(APP_LOG_LEVEL_DEBUG, "Done initializing, pushed window: %p", window);

  app_event_loop();
  deinit();
}
