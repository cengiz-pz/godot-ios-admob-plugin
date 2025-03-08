#!/usr/bin/env python
import os
import sys
import subprocess

if sys.version_info < (3,):
	def decode_utf8(x):
		return x
else:
	import codecs
	def decode_utf8(x):
		return codecs.utf_8_decode(x)[0]

plugin_name="AdmobPlugin"

opts = Variables([], ARGUMENTS)

# Gets the standard flags CC, CCX, etc.
env = DefaultEnvironment()

# Define our options
opts.Add(EnumVariable('target', "Compilation target", 'debug', ['debug', 'release', "release_debug"]))
opts.Add(EnumVariable('arch', "Compilation Architecture", '', ['', 'arm64', 'x86_64']))
opts.Add(BoolVariable('simulator', "Compilation platform", 'no'))
opts.Add(BoolVariable('use_llvm', "Use the LLVM / Clang compiler", 'no'))
opts.Add('target_name', 'Resulting file name.', '')
opts.Add(PathVariable('target_path', 'The path where the lib is installed.', 'bin/lib/'))
opts.Add(EnumVariable('version', 'Godot version to target', '', ['', '4.1', '4.2', '4.3', '4.4']))

# Updates the environment with the option variables.
opts.Update(env)

# Process some arguments
if env['use_llvm']:
	env['CC'] = 'clang'
	env['CXX'] = 'clang++'

if env['arch'] == '':
	print("No valid arch selected.")
	quit();

if env['version'] == '':
	print("No valid Godot version selected.")
	quit();

if env['target_name'] == '':
	print("No valid target name.")
	quit();

# For the reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# Enable Obj-C modules
env.Append(CCFLAGS=["-fmodules", "-fcxx-modules"])
architecture_directory = ''

if env['simulator']:
	architecture_directory = 'ios-arm64_x86_64-simulator'
	sdk_name = 'iphonesimulator'
	env.Append(CCFLAGS=['-mios-simulator-version-min=10.0'])
	env.Append(LINKFLAGS=["-mios-simulator-version-min=10.0"])
else:
	architecture_directory = 'ios-arm64'
	sdk_name = 'iphoneos'
	env.Append(CCFLAGS=['-miphoneos-version-min=10.0'])
	env.Append(LINKFLAGS=["-miphoneos-version-min=10.0"])

try:
	sdk_path = decode_utf8(subprocess.check_output(['xcrun', '--sdk', sdk_name, '--show-sdk-path']).strip())
except (subprocess.CalledProcessError, OSError):
	raise ValueError("Failed to find SDK path while running xcrun --sdk {} --show-sdk-path.".format(sdk_name))


env.Append(FRAMEWORKPATH=[f'#Pods/Google-Mobile-Ads-SDK/Frameworks/GoogleMobileAdsFramework/GoogleMobileAds.xcframework/{architecture_directory}'])
env.Append(FRAMEWORKPATH=[f'#Pods/GoogleUserMessagingPlatform/Frameworks/Release/UserMessagingPlatform.xcframework/{architecture_directory}'])


env.Append(CCFLAGS=[
	'-fobjc-arc', 
	'-fmessage-length=0', '-fno-strict-aliasing', '-fdiagnostics-print-source-range-info', 
	'-fdiagnostics-show-category=id', '-fdiagnostics-parseable-fixits', '-fpascal-strings', 
	'-fblocks', '-fvisibility=hidden', '-MMD', '-MT', 'dependencies', '-fno-exceptions', 
	'-Wno-ambiguous-macro', 
	'-Wall', '-Werror=return-type',
	# '-Wextra',
])

env.Append(CCFLAGS=['-arch', env['arch'], "-isysroot", "$IPHONESDK", "-stdlib=libc++", '-isysroot', sdk_path])
env.Append(CCFLAGS=['-DPTRCALL_ENABLED'])
env.Prepend(CXXFLAGS=[
	'-DNEED_LONG_INT', '-DLIBYUV_DISABLE_NEON', 
	'-DIPHONE_ENABLED', '-DUNIX_ENABLED', '-DCOREAUDIO_ENABLED'
])
env.Append(LINKFLAGS=["-arch", env['arch'], '-isysroot', sdk_path, '-F' + sdk_path])

env.Append(CCFLAGS=["$IOS_SDK_PATH"])
env.Prepend(CXXFLAGS=['-DIOS_ENABLED'])
env.Prepend(CXXFLAGS=['-DVERSION_4_0'])


if env['version'] == '4.1' or env['version'] == '4.2' or env['version'] == '4.3' or env['version'] == '4.4':
	env.Prepend(CFLAGS=['-std=gnu11'])
	env.Prepend(CXXFLAGS=['-std=gnu++17'])

	if env['target'] == 'debug':
		env.Prepend(CXXFLAGS=[
			'-gdwarf-2', '-O0', 
			'-DDEBUG_MEMORY_ALLOC', '-DDISABLE_FORCED_INLINE', 
			'-D_DEBUG', '-DDEBUG=1', '-DDEBUG_ENABLED', 
		])
	elif env['target'] == 'release_debug':
		env.Prepend(CXXFLAGS=[
			'-O2', '-ftree-vectorize',
			'-DNDEBUG', '-DNS_BLOCK_ASSERTIONS=1', '-DDEBUG_ENABLED',
		])

		env.Prepend(CXXFLAGS=['-fomit-frame-pointer'])
	else:
		env.Prepend(CXXFLAGS=[
			'-O2', '-ftree-vectorize',
			'-DNDEBUG', '-DNS_BLOCK_ASSERTIONS=1',
		])

		env.Prepend(CXXFLAGS=['-fomit-frame-pointer'])            
else:
	print("No valid Godot version to set flags for.")
	quit();

# Adding header files
env.Append(CPPPATH=[
	f'{plugin_name}',
	f'{plugin_name}/adformat',
	f'{plugin_name}/model',
	'godot',
	'godot/platform/ios'
])

# tweak this if you want to use different folders, or more folders, to store your source code in.
sources = Glob(f'{plugin_name}/*.cpp')
sources.append(Glob(f'{plugin_name}/*.mm'))
sources.append(Glob(f'{plugin_name}/*.m'))
sources.append(Glob(f'{plugin_name}/**/*.cpp'))
sources.append(Glob(f'{plugin_name}/**/*.mm'))
sources.append(Glob(f'{plugin_name}/**/*.m'))

# lib<plugin>.<arch>-<simulator|iphone>.<release|debug|release_debug>.a
library_platform = env["arch"] + "-" + ("simulator" if env["simulator"] else "ios")
library_name = env['target_name'] + "." + library_platform + "." + env["target"] + ".a"
library = env.StaticLibrary(target=env['target_path'] + library_name, source=sources)

Default(library)

# Generates help for the -h scons option.
Help(opts.GenerateHelpText(env))
