//
//  admob_plugin_implementation.h
//

#ifndef admob_plugin_implementation_h
#define admob_plugin_implementation_h

#include "core/object/object.h"
#include "core/object/class_db.h"

class AdmobPlugin : public Object {
	GDCLASS(AdmobPlugin, Object);
	
	static void _bind_methods();
	
public:
	
	Error foo();
	
	AdmobPlugin();
	~AdmobPlugin();
};

#endif /* admob_plugin_implementation_h */
