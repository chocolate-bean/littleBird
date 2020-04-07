local crypto = {}

function crypto.md5(input)
    input = tostring(input)
    return CSharpTools.md5(input)
end

function crypto.encodeBase64(input)
    input = tostring(input)
    return CSharpTools.Base64Encode(input)
end

function crypto.decodeBase64(input)
    input = tostring(input)
    return CSharpTools.Base64Decode(input)
end

return crypto