module std::io::os @if(env::LIBC);
import std::io::path, std::os;

fn Path! native_temp_directory(Allocator allocator) @if(!env::WIN32)
{
	foreach (String env : { "TMPDIR", "TMP", "TEMP", "TEMPDIR" })
	{
		String tmpdir = env::tget_var(env) ?? "";
		if (tmpdir) return path::new(allocator, tmpdir);
	}
	return path::new(allocator, "/tmp");
}

fn Path! native_temp_directory(Allocator allocator) @if(env::WIN32) => @pool(allocator)
{
	Win32_DWORD len = win32::getTempPathW(0, null);
	if (!len) return IoError.GENERAL_ERROR?;
	Char16[] buff = mem::temp_alloc_array(Char16, len + (usz)1);
	if (!win32::getTempPathW(len, buff)) return IoError.GENERAL_ERROR?;
	return path::new(allocator, string::temp_from_utf16(buff[:len]));
}

module std::io::os @if(env::NO_LIBC);
import std::io::path;

macro Path! native_temp_directory(Allocator allocator = allocator::heap())
{
	return IoError.UNSUPPORTED_OPERATION?;
}
