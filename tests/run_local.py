"""Local Lua 5.1 checks with simulated WoW APIs; does not replace in-game tests."""
import ctypes
import os
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
os.chdir(ROOT)
lua_path = Path(os.environ.get("TARTARO_LUA51_DLL", r"C:\Program Files\obs-studio\bin\64bit\lua51.dll"))
if os.name == "nt":
    os.add_dll_directory(str(lua_path.parent))
lua = ctypes.CDLL(str(lua_path))
lua.luaL_newstate.restype = ctypes.c_void_p
lua.luaL_openlibs.argtypes = [ctypes.c_void_p]
lua.luaL_loadbuffer.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p]
lua.lua_pcall.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int]
lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
lua.lua_tolstring.restype = ctypes.c_char_p
lua.lua_settop.argtypes = [ctypes.c_void_p, ctypes.c_int]
lua.lua_close.argtypes = [ctypes.c_void_p]
state = lua.luaL_newstate()
lua.luaL_openlibs(state)
try:
    for path in (ROOT / "Tartaro").glob("*.lua"):
        source = path.read_bytes()
        if lua.luaL_loadbuffer(state, source, len(source), str(path).encode()):
            raise AssertionError(lua.lua_tolstring(state, -1, None).decode())
        lua.lua_settop(state, 0)
        assert not any(ord(c) > 255 for c in source.decode("utf-8-sig")), f"Unsupported glyph: {path}"
    ET.parse(ROOT / "Tartaro/MapPin.xml")
    for name in ["issues.lua", "ui.lua", "orders_flow.lua", "replication.lua"]:
        path = ROOT / "tests" / name
        if not path.exists():
            continue
        source = path.read_bytes()
        if lua.luaL_loadbuffer(state, source, len(source), name.encode()) or lua.lua_pcall(state, 0, 0, 0):
            raise AssertionError(lua.lua_tolstring(state, -1, None).decode())
    print("Lua compilation, XML, glyph checks and local regression tests passed.")
finally:
    lua.lua_close(state)
