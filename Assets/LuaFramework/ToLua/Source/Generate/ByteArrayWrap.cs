﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class ByteArrayWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(ByteArray), typeof(System.Object));
		L.RegFunction("Close", Close);
		L.RegFunction("WriteByte", WriteByte);
		L.RegFunction("WriteInt", WriteInt);
		L.RegFunction("WriteShort", WriteShort);
		L.RegFunction("WriteBuffer", WriteBuffer);
		L.RegFunction("ReadInt", ReadInt);
		L.RegFunction("ReadShort", ReadShort);
		L.RegFunction("ReadByte", ReadByte);
		L.RegFunction("ReadBuffer", ReadBuffer);
		L.RegFunction("write", write);
		L.RegFunction("read", read);
		L.RegFunction("Reposition", Reposition);
		L.RegFunction("SetPosition", SetPosition);
		L.RegFunction("getBuff", getBuff);
		L.RegFunction("checkLua", checkLua);
		L.RegFunction("New", _CreateByteArray);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("Position", get_Position, null);
		L.RegVar("Length", get_Length, null);
		L.RegVar("Readnable", get_Readnable, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateByteArray(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				ByteArray obj = new ByteArray();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else if (count == 1)
			{
				byte[] arg0 = ToLua.CheckByteBuffer(L, 1);
				ByteArray obj = new ByteArray(arg0);
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: ByteArray.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Close(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
			obj.Close();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int WriteByte(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
			byte arg0 = (byte)LuaDLL.luaL_checknumber(L, 2);
			obj.WriteByte(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int WriteInt(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.WriteInt(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int WriteShort(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
			short arg0 = (short)LuaDLL.luaL_checknumber(L, 2);
			obj.WriteShort(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int WriteBuffer(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes<LuaInterface.LuaByteBuffer>(L, 2))
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				LuaByteBuffer arg0 = new LuaByteBuffer(ToLua.CheckByteBuffer(L, 2));
				obj.WriteBuffer(arg0);
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes<byte[]>(L, 2))
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				byte[] arg0 = ToLua.CheckByteBuffer(L, 2);
				obj.WriteBuffer(arg0);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: ByteArray.WriteBuffer");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadInt(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
			int o = obj.ReadInt();
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadShort(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
			int o = obj.ReadShort();
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadByte(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
			byte o = obj.ReadByte();
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadBuffer(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			byte[] o = obj.ReadBuffer(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int write(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes<bool>(L, 2))
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				bool arg0 = LuaDLL.lua_toboolean(L, 2);
				obj.write(arg0);
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes<string>(L, 2))
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				obj.write(arg0);
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes<byte[]>(L, 2))
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				byte[] arg0 = ToLua.CheckByteBuffer(L, 2);
				obj.write(arg0);
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes<double>(L, 2))
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				double arg0 = (double)LuaDLL.lua_tonumber(L, 2);
				obj.write(arg0);
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes<long>(L, 2))
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				long arg0 = LuaDLL.tolua_toint64(L, 2);
				obj.write(arg0);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: ByteArray.write");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int read(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes<LuaInterface.LuaOut<int>>(L, 2))
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				int arg0;
				obj.read(out arg0);
				LuaDLL.lua_pushinteger(L, arg0);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes<LuaInterface.LuaOut<byte>>(L, 2))
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				byte arg0;
				obj.read(out arg0);
				LuaDLL.lua_pushnumber(L, arg0);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes<LuaInterface.LuaOut<bool>>(L, 2))
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				bool arg0;
				obj.read(out arg0);
				LuaDLL.lua_pushboolean(L, arg0);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes<LuaInterface.LuaOut<string>>(L, 2))
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				string arg0 = null;
				obj.read(out arg0);
				LuaDLL.lua_pushstring(L, arg0);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes<LuaInterface.LuaOut<double>>(L, 2))
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				double arg0;
				obj.read(out arg0);
				LuaDLL.lua_pushnumber(L, arg0);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes<LuaInterface.LuaOut<float>>(L, 2))
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				float arg0;
				obj.read(out arg0);
				LuaDLL.lua_pushnumber(L, arg0);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes<LuaInterface.LuaOut<long>>(L, 2))
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				long arg0;
				obj.read(out arg0);
				LuaDLL.tolua_pushint64(L, arg0);
				return 1;
			}
			else if (count == 3)
			{
				ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
				byte[] arg0 = null;
				int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
				obj.read(out arg0, arg1);
				ToLua.Push(L, arg0);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: ByteArray.read");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Reposition(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
			obj.Reposition();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetPosition(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.SetPosition(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int getBuff(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
			byte[] o = obj.getBuff();
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int checkLua(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ByteArray obj = (ByteArray)ToLua.CheckObject<ByteArray>(L, 1);
			LuaByteBuffer arg0 = new LuaByteBuffer(ToLua.CheckByteBuffer(L, 2));
			LuaInterface.LuaByteBuffer o = obj.checkLua(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Position(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ByteArray obj = (ByteArray)o;
			int ret = obj.Position;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Position on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Length(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ByteArray obj = (ByteArray)o;
			int ret = obj.Length;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Length on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Readnable(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ByteArray obj = (ByteArray)o;
			bool ret = obj.Readnable;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Readnable on a nil value");
		}
	}
}

