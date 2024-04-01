//
//  admob_plugin.mm
//

#import <Foundation/Foundation.h>

#import "admob_plugin.h"
#import "admob_plugin_implementation.h"

#import "core/config/engine.h"


AdmobPlugin *plugin;

void admob_plugin_init() {
	NSLog(@"init plugin");

	plugin = memnew(AdmobPlugin);
	Engine::get_singleton()->add_singleton(Engine::Singleton("AdmobPlugin", plugin));
}

void admob_plugin_deinit() {
	NSLog(@"deinit plugin");
	
	if (plugin) {
	   memdelete(plugin);
   }
}
