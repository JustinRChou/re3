Librw = os.getenv("LIBRW") or "librw"

workspace "re3"
	configurations { "Debug", "Release", "ReleaseFH", "DebugRW", "ReleaseRW", "ReleaseGLFW"  }
	location "build"

	files { "src/*.*" }
	files { "src/animation/*.*" }
	files { "src/audio/*.*" }
	files { "src/control/*.*" }
	files { "src/core/*.*" }
	files { "src/entities/*.*" }
	files { "src/math/*.*" }
	files { "src/modelinfo/*.*" }
	files { "src/objects/*.*" }
	files { "src/peds/*.*" }
	files { "src/render/*.*" }
	files { "src/rw/*.*" }
	files { "src/save/*.*" }
	files { "src/skel/*.*" }
	files { "src/skel/win/*.*" }
	files { "src/skel/glfw/*.*" }
	files { "src/text/*.*" }
	files { "src/vehicles/*.*" }
	files { "src/weapons/*.*" }
	files { "src/extras/*.*" }
	files { "eax/*.*" }

	includedirs { "src" }
	includedirs { "src/animation" }
	includedirs { "src/audio" }
	includedirs { "src/control" }
	includedirs { "src/core" }
	includedirs { "src/entities" }
	includedirs { "src/math" }
	includedirs { "src/modelinfo" }
	includedirs { "src/objects" }
	includedirs { "src/peds" }
	includedirs { "src/render" }
	includedirs { "src/rw" }
	includedirs { "src/save/" }
	includedirs { "src/skel/" }
	includedirs { "src/skel/win" }
	includedirs { "src/skel/glfw" }
	includedirs { "src/text" }
	includedirs { "src/vehicles" }
	includedirs { "src/weapons" }
	includedirs { "src/extras" }
	includedirs { "eax" }

	includedirs { "dxsdk/include" }
	includedirs { "milessdk/include" }
	includedirs { "eax" }

	libdirs { "dxsdk/lib" }
	libdirs { "milessdk/lib" }

	filter "configurations:Debug or Release"
		files { "src/fakerw/*.*" }
		includedirs { "src/fakerw" }
		includedirs { Librw }
		libdirs { path.join(Librw, "lib/win-x86-d3d9/%{cfg.buildcfg}") }
		links { "rw", "d3d9" }
	filter  {}
	
	filter "configurations:DebugRW or ReleaseRW"
		includedirs { "rwsdk/include/d3d8" }
		libdirs { "rwsdk/lib/d3d8/release" }
		links { "rwcore", "rpworld", "rpmatfx", "rpskin", "rphanim", "rtbmp", "rtquat", "rtcharse" }
	filter  {}

	filter "configurations:ReleaseGLFW"
		defines { "GLEW_STATIC", "GLFW_DLL" }
		files { "src/fakerw/*.*" }
		includedirs { "src/fakerw" }
		includedirs { Librw }
		includedirs { "glfw-3.3.2.bin.WIN32/include" }
		includedirs { "glew-2.1.0/include" }
		libdirs { path.join(Librw, "lib/win-x86-gl3/Release") }
		libdirs { "glew-2.1.0/lib/Release/Win32" }
		libdirs { "glfw-3.3.2.bin.WIN32/lib-vc2015" }
		links { "opengl32" }
		links { "glew32s" }
		links { "glfw3dll" }
		links { "rw" }
	filter  {}
	
    pbcommands = { 
       "setlocal EnableDelayedExpansion",
       "set file=$(TargetPath)",
       "FOR %%i IN (\"%file%\") DO (",
       "set filename=%%~ni",
       "set fileextension=%%~xi",
       "set target=!path!!filename!!fileextension!",
       "copy /y \"!file!\" \"!target!\"",
       ")" }
    
    function setpaths (gamepath, exepath, scriptspath)
       scriptspath = scriptspath or ""
       if (gamepath) then
          cmdcopy = { "set \"path=" .. gamepath .. scriptspath .. "\"" }
          table.insert(cmdcopy, pbcommands)
          postbuildcommands (cmdcopy)
          debugdir (gamepath)
          if (exepath) then
             debugcommand (gamepath .. exepath)
             dir, file = exepath:match'(.*/)(.*)'
             debugdir (gamepath .. (dir or ""))
          end
       end
       --targetdir ("bin/%{prj.name}/" .. scriptspath)
    end

project "re3"
	kind "WindowedApp"
	language "C++"
	targetname "re3"
	targetdir "bin/%{cfg.buildcfg}"
	targetextension ".exe"
	characterset ("MBCS")
	linkoptions "/SAFESEH:NO"
	
	setpaths("$(GTA_III_RE_DIR)/", "$(TargetFileName)", "")
	symbols "Full"
	staticruntime "off"
	
	filter "configurations:Debug or Release or ReleaseFH"
		prebuildcommands { "cd \"../librw\" && premake5 " .. _ACTION .. " && msbuild \"build/librw.sln\" /property:Configuration=%{cfg.longname} /property:Platform=\"win-x86-d3d9\"" }
		defines { "LIBRW", "RW_D3D9" }
	
	filter "configurations:*RW"
		defines { "RWLIBS" }
		staticruntime "on"
		linkoptions "/SECTION:_rwcseg,ER!W /MERGE:_rwcseg=.text"

	filter "configurations:*GLFW"
		prebuildcommands { "cd \"../librw\" && premake5 " .. _ACTION .. " && msbuild \"build/librw.sln\" /property:Configuration=Release /property:Platform=\"win-x86-gl3\"" }
		defines { "LIBRW", "RW_GL3" }
		
	filter "configurations:Debug*"
		defines { "DEBUG" }
		
	filter "configurations:Release*"
		defines { "NDEBUG" }
		optimize "On"

		
	filter "configurations:ReleaseFH"
		prebuildcommands {}
		optimize "off"
		staticruntime "on"

