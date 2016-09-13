libcryptopp = {
	settings = nil,
}

function libcryptopp.setup(settings)
	if not settings.source then error("Missing source.") end

	libcryptopp.settings = settings
end

function libcryptopp.import()
	if not libcryptopp.settings then error("Run libcryptopp.setup first") end

	libcryptopp.links()
	libcryptopp.includes()
end

function libcryptopp.links()
	links { "libcryptopp" }
end

function libcryptopp.includes()
	if not libcryptopp.settings then error("Run libcryptopp.setup first") end
	
	--defines { "CRYPTOPP_IMPORTS" }
	
	--filter "*Static"
	--	removedefines { "CRYPTOPP_IMPORTS" }

	filter "Debug*"
		defines { "_DEBUG" }

	filter "Release*"
		defines { "NDEBUG" }

	filter "system:windows"
		defines { "_WINDOWS", "WIN32" }
	filter {}

	includedirs { libcryptopp.settings.source }
end

function libcryptopp.project()
	if not libcryptopp.settings then error("Run libcryptopp.setup first") end

	rule "MASM_dummy"
		location "./build"
		fileextension ""
		filename "masm_dummy"

	externalrule "MASM"
		filename "masm_dummy"
		location "./build"
		buildmessage "Building and assembling %(Identity)..."
		propertydefinition {
			name = "PreprocessorDefinitions",
			kind = "string",
			value = "",
			switch = "/D",
		}
		propertydefinition {
			name = "UseSafeExceptionHandlers",
			kind = "boolean",
			value = false,
			switch = "/safeseh",
		}

	--[[
	rule "CustomProtoBuildTool"
		display "C++ prototype copy"
		location "./build"
		fileExtension ".proto"
		buildmessage "Preparing %(Identity)..."
		buildcommands {
			'if not exist "$(ProjectDir)\\src\\%(Filename)" copy "%(Identity)" "$(ProjectDir)\\src\\%(Filename)"',
			'echo: >> "src\\%(Filename).copied"',
		}
		buildoutputs {
			'$(ProjectDir)\\src\\%(Filename)',
		}
	]]

	project "libcryptopp"
		language "C++"
		characterset "MBCS"

		defines {
			"USE_PRECOMPILED_HEADERS"
		}
		includedirs
		{
			libcryptopp.settings.source,
		}
		files
		{
			path.join(libcryptopp.settings.source, "*.cpp"),
			--path.join(libcryptopp.settings.source, "*.cpp.proto"),
			path.join(libcryptopp.settings.source, "*.h"),
			path.join(libcryptopp.settings.source, "*.txt"),
		}

		removefiles {
			path.join(libcryptopp.settings.source, "eccrypto.cpp"),
			path.join(libcryptopp.settings.source, "eprecomp.cpp"),
			path.join(libcryptopp.settings.source, "bench*"),
			path.join(libcryptopp.settings.source, "*test.*"),
			path.join(libcryptopp.settings.source, "fipsalgt.*"),
			path.join(libcryptopp.settings.source, "cryptlib_bds.*"),
			path.join(libcryptopp.settings.source, "validat*.*"),
			
			-- Remove linker warnings
			path.join(libcryptopp.settings.source, "strciphr.cpp"),
			path.join(libcryptopp.settings.source, "simple.cpp"),
			path.join(libcryptopp.settings.source, "polynomi.cpp"),
			path.join(libcryptopp.settings.source, "algebra.cpp"),
		}

		-- Pre-compiled header
		pchheader "pch.h" -- must be exactly same as used in #include directives
		pchsource(path.join(libcryptopp.settings.source, "pch.cpp")) -- real path

		defines { "_SCL_SECURE_NO_WARNINGS" }
		warnings "Off"

		vectorextensions "SSE"

		rules {
			"MASM",
			--"CustomProtoBuildTool",
		}
		
		-- SharedLib needs that
		--links { "Ws2_32" }
		
		--kind "SharedLib"
		--filter "*Static"
			kind "StaticLib"

		filter "kind:SharedLib"
			defines { "CRYPTOPP_EXPORTS" }

		filter "architecture:x86"
			exceptionhandling "SEH"
			masmVars {
				UseSafeExceptionHandlers = true,
				PreprocessorDefinitions = "_M_X86",
			}
		filter "architecture:x64"
			files {
				path.join(libcryptopp.settings.source, "x64masm.asm"),
			}
			masmVars {
				PreprocessorDefinitions = "_M_X64",
			}
		filter { "architecture:x64", "kind:SharedLib" }
			files {
				path.join(libcryptopp.settings.source, "x64dll.asm"),
			}

		filter("files:" .. path.join(libcryptopp.settings.source, "dll.cpp")
			.. " or files:" .. path.join(libcryptopp.settings.source, "iterhash.cpp"))
			flags { "NoPCH" }
end
