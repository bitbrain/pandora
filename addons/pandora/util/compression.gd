const BLOCK_SIZE = 4096
const MAGIC = "GCPF"


## magic
##     char[4] "GCPF"
##
## header
##     uint32_t compression_mode (Compression::MODE_ZSTD by default)
##     uint32_t block_size (4096 by default)
##     uint32_t uncompressed_size
##
## block compressed sizes, number of blocks = (uncompressed_size / block_size) + 1
##     uint32_t block_sizes[]
##
## followed by compressed block data, same as calling `compress` for each source `block_size`
static func compress(text: String, compression_mode:FileAccess.CompressionMode = FileAccess.COMPRESSION_FASTLZ) -> PackedByteArray:
	var data = _encode_string(text)
	var uncompressed_size = data.size()

	var num_blocks = int(ceil(float(uncompressed_size) / BLOCK_SIZE))

	var buffer = PackedByteArray()

	buffer.append_array(_encode_string(MAGIC))

	buffer.append_array(_encode_uint32(compression_mode))
	buffer.append_array(_encode_uint32(BLOCK_SIZE))
	buffer.append_array(_encode_uint32(uncompressed_size))

	var block_sizes = PackedByteArray()
	var compressed_blocks = []

	for i in range(num_blocks):
		var start = i * BLOCK_SIZE
		var end = min((i + 1) * BLOCK_SIZE, uncompressed_size)
		var block_data = PackedByteArray()
		var block_index = start
		while block_index < end:
			block_data.append(data[block_index])
			block_index += 1

		var compressed_block = block_data.compress(compression_mode)
		block_sizes.append_array(_encode_uint32(compressed_block.size()))
		compressed_blocks.append(compressed_block)

	buffer.append_array(block_sizes)

	for block in compressed_blocks:
		buffer.append_array(block)

	return buffer


static func _encode_uint32(value: int) -> PackedByteArray:
	var arr = PackedByteArray()
	arr.append(value & 0xFF)
	arr.append((value >> 8) & 0xFF)
	arr.append((value >> 16) & 0xFF)
	arr.append((value >> 24) & 0xFF)
	return arr


static func _encode_string(value: String) -> PackedByteArray:
	var arr = PackedByteArray()
	for char in value:
		arr.append_array(char.to_ascii_buffer())
	return arr
