using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Net.Sockets;
using UnityEngine;
using LuaFramework;
// using Nkclient;
// using Google.Protobuf;

//WARNING!!!
//使用异步Socket模式，请务必要求server修改消息传输模型，否则无法判断消息的完整性！
public class NetFramework
{
    public static byte[] SendByteMap = new byte[256]
    {
        0x72,0x67,0x6d,0xf3,0xcd,0x73,0x85,0x97,0xf6,0x08,0xdc,0xc2,0xef,0x54,0xb6,0xd6,
        0x7a,0xc6,0x02,0x59,0x15,0xfc,0x48,0xab,0xa5,0x5f,0xf9,0xa3,0x1b,0xed,0x93,0x31,
        0xaa,0x32,0x9f,0x28,0xc3,0x16,0x3f,0x25,0x4b,0x47,0x1c,0x6c,0x2c,0xd8,0xd9,0x78,
        0x3c,0x29,0x1f,0x5b,0xf4,0xb3,0x56,0x8b,0xbd,0x8e,0x9a,0xad,0x24,0x44,0x14,0x0a,
        0xbb,0xcf,0x89,0x37,0xa1,0x41,0xba,0xbf,0x2a,0x81,0x20,0x77,0x70,0x33,0x58,0x7f,
        0x05,0x6b,0x5d,0x84,0xf0,0xa8,0x64,0x7c,0x2d,0x00,0x2e,0x1a,0xd2,0xd7,0x9d,0x7b,
        0xd3,0x86,0x88,0x4c,0xe5,0x92,0xfd,0x01,0xdf,0x71,0xc5,0x9b,0x3a,0x38,0xa0,0x10,
        0x43,0xd1,0x61,0x98,0xa7,0xb0,0x12,0x65,0x36,0x7e,0x7d,0xce,0xbe,0x68,0xff,0x3d,
        0xf8,0x27,0x5a,0x18,0x1e,0xdd,0x0b,0xa2,0x19,0x35,0x53,0x87,0xc0,0xe7,0xcb,0xb8,
        0x17,0x83,0xc1,0x04,0x22,0x96,0xa9,0x8a,0x69,0xf7,0x52,0xec,0x34,0xe0,0xd4,0x1d,
        0x60,0xe8,0x0e,0xe2,0xde,0x91,0x95,0xb1,0x4f,0x66,0xf5,0x6e,0x5e,0xac,0x74,0xe4,
        0xb5,0xb2,0x8f,0xc4,0xa6,0x9e,0xda,0x90,0x9c,0x8c,0x6f,0xb7,0x07,0xea,0xf1,0xc9,
        0x0f,0x80,0x82,0xfe,0x79,0x4a,0x21,0x49,0x2f,0xbc,0xe6,0xee,0x0d,0x40,0x30,0xb9,
        0x4e,0x46,0x4d,0x94,0xe3,0xae,0x55,0x03,0x06,0x62,0xd5,0x42,0xb4,0xe1,0x26,0x75,
        0xdb,0xfa,0x3e,0x45,0x6a,0xa4,0x3b,0x57,0xca,0xe9,0xaf,0x13,0x5c,0x0c,0x51,0xc7,
        0xd0,0x39,0xeb,0xcc,0xf2,0xc8,0x09,0x76,0x11,0x63,0x99,0x2b,0x8d,0x23,0xfb,0x50
    };

    public static byte[] RecvByteMap = new byte[256]
    {
        0x59,0x67,0x12,0xd7,0x93,0x50,0xd8,0xbc,0x09,0xf6,0x3f,0x86,0xed,0xcc,0xa2,0xc0,
        0x6f,0xf8,0x76,0xeb,0x3e,0x14,0x25,0x90,0x83,0x88,0x5b,0x1c,0x2a,0x9f,0x84,0x32,
        0x4a,0xc6,0x94,0xfd,0x3c,0x27,0xde,0x81,0x23,0x31,0x48,0xfb,0x2c,0x58,0x5a,0xc8,
        0xce,0x1f,0x21,0x4d,0x9c,0x89,0x78,0x43,0x6d,0xf1,0x6c,0xe6,0x30,0x7f,0xe2,0x26,
        0xcd,0x45,0xdb,0x70,0x3d,0xe3,0xd1,0x29,0x16,0xc7,0xc5,0x28,0x63,0xd2,0xd0,0xa8,
        0xff,0xee,0x9a,0x8a,0x0d,0xd6,0x36,0xe7,0x4e,0x13,0x82,0x33,0xec,0x52,0xac,0x19,
        0xa0,0x72,0xd9,0xf9,0x56,0x77,0xa9,0x01,0x7d,0x98,0xe4,0x51,0x2b,0x02,0xab,0xba,
        0x4c,0x69,0x00,0x05,0xae,0xdf,0xf7,0x4b,0x2f,0xc4,0x10,0x5f,0x57,0x7a,0x79,0x4f,
        0xc1,0x49,0xc2,0x91,0x53,0x06,0x61,0x8b,0x62,0x42,0x97,0x37,0xb9,0xfc,0x39,0xb2,
        0xb7,0xa5,0x65,0x1e,0xd3,0xa6,0x95,0x07,0x73,0xfa,0x3a,0x6b,0xb8,0x5e,0xb5,0x22,
        0x6e,0x44,0x87,0x1b,0xe5,0x18,0xb4,0x74,0x55,0x96,0x20,0x17,0xad,0x3b,0xd5,0xea,
        0x75,0xa7,0xb1,0x35,0xdc,0xb0,0x0e,0xbb,0x8f,0xcf,0x46,0x40,0xc9,0x38,0x7c,0x47,
        0x8c,0x92,0x0b,0x24,0xb3,0x6a,0x11,0xef,0xf5,0xbf,0xe8,0x8e,0xf3,0x04,0x7b,0x41,
        0xf0,0x71,0x5c,0x60,0x9e,0xda,0x0f,0x5d,0x2d,0x2e,0xb6,0xe0,0x0a,0x85,0xa4,0x68,
        0x9d,0xdd,0xa3,0xd4,0xaf,0x64,0xca,0x8d,0xa1,0xe9,0xbd,0xf2,0x9b,0x1d,0xcb,0x0c,
        0x54,0xbe,0xf4,0x03,0x34,0xaa,0x08,0x99,0x80,0x1a,0xe1,0xfe,0x15,0x66,0xc3,0x7e
    };

    public static Socket socket;

    public static byte[] readbuff = new byte[1024];

    public static List<byte> cache = new List<byte>();

    public static bool isReading = false;
    public static void Connect(String address, int port)
    {
        try
        {
            IPAddress[] ipaddress = Dns.GetHostAddresses(address);
            if (ipaddress[0].AddressFamily == AddressFamily.InterNetworkV6)
            {
                socket = new Socket(AddressFamily.InterNetworkV6, SocketType.Stream, ProtocolType.Tcp);
            }
            else
            {
                socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            }
            //创建客户端连接对象
            socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            //连接到服务器
            socket.Connect(address, port);
            AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua).CallConnected();
            //开启异步消息接收 消息到达后会直接写入 缓冲区 readbuff
            socket.BeginReceive(readbuff, 0, 1024, SocketFlags.None, ReceiveCallBack, readbuff);
        }
        catch (Exception e)
        {
            Debug.Log(e.Message);
        }
    }

    //收到消息回调
    private static void ReceiveCallBack(IAsyncResult ar)
    {
        try
        {
            //获取当前收到的消息长度()
            int length = socket.EndReceive(ar);
            byte[] message = new byte[length];
            Buffer.BlockCopy(readbuff, 0, message, 0, length);
            cache.AddRange(message);
            if (!isReading)
            {
                isReading = true;
                onData();
            }
            //尾递归 再次开启异步消息接收 消息到达后会直接写入 缓冲区 readbuff
            socket.BeginReceive(readbuff, 0, 1024, SocketFlags.None, ReceiveCallBack, readbuff);
        }
        catch (Exception e)
        {
            Debug.Log("远程服务器主动断开连接" + e.Message);
            socket.Close();

        }
    }

    public static void BrokenConnect()
    {
        socket.Close();
    }

    //缓存中有数据处理
    public static void onData()
    {
        //长度解码
        byte[] result = decode(ref cache);

        //长度解码返回空 说明消息体不全，等待下条消息过来补全
        if (result == null)
        {
            isReading = false;
            return;
        }

        //decode方法反编message

        byte[] message = messageDecode(result);
        
        // 这里开始解析之前的值
        read(message);

        LuaManager.AddEvent(new ByteArray(message));

        if (message == null)
        {
            isReading = false;
            return;
        }

        //尾递归 防止在消息处理过程中 有其他消息到达而没有经过处理
        onData();
    }

    public static byte[] decode(ref List<byte> cache)
    {
        if (cache.Count < 4) return null;

        MemoryStream ms = new MemoryStream(cache.ToArray());//创建内存流对象，并将缓存数据写入进去
        BinaryReader br = new BinaryReader(ms);//二进制读取流

        //从缓存中读取int型消息体长度
        //如果消息体长度 大于缓存中数据长度 说明消息没有读取完 等待下次消息到达后再次处理
        int length = br.ReadInt32();
        length = System.Net.IPAddress.NetworkToHostOrder(length);
        if (length > ms.Length - ms.Position)
        {
            return null;
        }

        //读取正确长度的数据
        //注意这里ms的position已经移动到了第4位，接下来会从第五位开始读取指定的长度
        //如果需要包括包头的消息体，需要将ms.Position = 0，然后读取length + 4
        ms.Position = 0;
        byte[] result = br.ReadBytes(length + 4);
        //清空缓存
        cache.Clear();
        //将读取后的剩余数据写入缓存
        cache.AddRange(br.ReadBytes((int)(ms.Length + 4 - ms.Position)));
        br.Close();
        ms.Close();
        return result;
    }

    public static byte[] messageDecode(byte[] value)
    {
        //这里要判断消息体是否需要二次检测
        //需要解密要在这里处理
        byte[] decodeBuff = DecodeBuffer(value);

        return decodeBuff;
    }

    public static void SendMessage(ByteArray byteArray)
    {
        try
        {
            //同步消息发送
            byte[] sendBuff = byteArray.getBuff();
            sendBuff = EncodeBuffer(sendBuff);
            socket.Send(sendBuff);
            //异步消息发送
            //sendSAEA.SetBuffer(ba.getBuff(), 0, ba.getBuff().Length);
            //bool result = socket.SendAsync(sendSAEA);
            //这里要判断是否挂起同步的send发送
            //if (!result)
            //{
            //    if (sendSAEA.SocketError != SocketError.Success)
            //    {
            //        Debug.Log("网络错误，请重新登录" + sendSAEA.Message);
            //    }
            //}
        }
        catch (Exception e)
        {
            Debug.Log("网络错误，请重新登录" + e.Message);
            AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua).CallNetworkErrorCallBack();
        }
    }

    public static byte[] EncodeBuffer(byte[] sendBuff)
    {
        byte[] encodeBuff = sendBuff;
        int startPos = 16;
        byte checkCode = 0;
        for (int i = startPos; i < encodeBuff.Length; i++)
        {
            checkCode += encodeBuff[i];
            encodeBuff[i] = SendByteMap[encodeBuff[i]];
        }

        encodeBuff[15] = (byte)(~checkCode + 1);

        return encodeBuff;
    }

    public static byte[] DecodeBuffer(byte[] receBuff)
    {
        byte[] decodeBuff = receBuff;
        //如果是截取了包长的应该从13开始
        int startPos = 16;
        byte checkCode = decodeBuff[15];
        for (int i = startPos; i < decodeBuff.Length; i++)
        {
            decodeBuff[i] = RecvByteMap[decodeBuff[i]];
            checkCode += decodeBuff[i];
        }

        //如果是截取了包长的应该是第11位
        if(checkCode != 0)
        {
            return null;
        }

        return decodeBuff;
    }

    public static void read(byte[] message)
    {
        // 改为在CSharp里面解析
        ByteArray array = new ByteArray(message);
        /*
           序号 字节  字节数 类型     意义     描述
            0  0000    4   Int     0       包大小 后接12个字节
            4  00      2   Short   TP      
            6  0       1   Byte    1
            7  00      2   Short   gameID
            9  0000    4   Int     cmd
            13 00      2   Short   subCmd
            15 0       1   Byte    0
        */
        array.SetPosition(4);
        byte T = array.ReadByte();
        byte P = array.ReadByte();
        byte[] TPByte = new byte[] {T, P};
        string TPString = System.Text.Encoding.ASCII.GetString(TPByte);

        if (TPString.Equals("TP"))
        {
            array.SetPosition(7);
            int gid = array.ReadShort();
            int cmd = array.ReadInt();

            int len = array.Length - 16;
            array.SetPosition(16);
            if (len >= 4)
            {
                int protoBufLen = array.ReadInt();
                byte[] protoBufData = array.ReadBuffer(protoBufLen - 1);

                LuaManager.AddEvent(cmd, protoBufData);

                // if (cmd.Equals(0x101))
                // {
                //     SendTableInfo info = SendTableInfo.Parser.ParseFrom(protoBufData);
                //     Debug.Log(info);
                // }
                // if (FishingGameControl.Instance)
                // {
                //     FishingGameControl.Instance.addServerLister(cmd, protoBufData);
                // }

            }
        }
    }

    public static ByteArray writer(int cmd, byte[] byteArray) 
    {
        ByteArray array = new ByteArray();
        /*
           序号 字节  字节数 类型     意义     描述
            0  0000    4   Int     size    包大小 后接12个字节
            4  00      2   Short   TP      
            6  0       1   Byte    1
            7  00      2   Short   gameID
            9  0000    4   Int     cmd
            13 00      2   Short   subCmd
            15 0       1   Byte    0
        */
        array.WriteInt(0);
        // TP
        array.WriteByte(System.Text.Encoding.Default.GetBytes("T")[0]);
        array.WriteByte(System.Text.Encoding.Default.GetBytes("P")[0]);
        array.WriteByte(1);
        // gameId
        array.WriteShort(7);
        // cmd
        array.WriteInt(cmd);
        // subCmd
        array.WriteShort(0);
        // 0
        array.WriteByte(0);
        if (byteArray != null)
        {
            array.WriteBuffer(byteArray);
        }
        array.SetPosition(0);
        array.WriteInt(array.Length - 4);
        return array;
    }

    public static void SendCmdMessage(int cmd, byte[] byteArray)
    {
        ByteArray array = writer(cmd, byteArray);
        SendMessage(array);
    }

}
