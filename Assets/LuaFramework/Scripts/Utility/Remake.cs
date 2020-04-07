using System;
using System.IO;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// class RemarkAttribute : Attribute {

//     public string Remark;
//     public RemarkAttribute(string Remark) {
//         this.Remark = Remark;
//     }
// }

// static class EnumExtension {
//     public static string GetRemark(this Enum value) {
//         FieldInfo info = value.GetType().GetField(value.ToString());
//         if (info == null) {
//             return string.Empty;
//         }
//         RemarkAttribute remarkAttribute = (RemarkAttribute)info.GetCustomAttributes(typeof(RemarkAttribute), true)[0];
//         return remarkAttribute.Remark;
//     }
// }