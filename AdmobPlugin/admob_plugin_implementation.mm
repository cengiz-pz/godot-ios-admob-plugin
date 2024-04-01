//
//  admob_plugin_implementation.mm
//

#import <Foundation/Foundation.h>

#include "core/config/project_settings.h"

#import "admob_plugin_implementation.h"


void AdmobPlugin::_bind_methods() {
	ClassDB::bind_method(D_METHOD("foo"), &AdmobPlugin::foo);
}

Error AdmobPlugin::foo() {
	NSLog(@"foo");
	return OK;
}

AdmobPlugin::AdmobPlugin() {
	NSLog(@"initialize object");
}

AdmobPlugin::~AdmobPlugin() {
	NSLog(@"deinitialize object");
}
