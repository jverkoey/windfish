
all: Sources/DisassemblyRequest/disassembly_request.pb.swift Sources/gbdis/disassembly_request.pb.swift

Sources/DisassemblyRequest/disassembly_request.pb.swift: disassembly_request.proto
	protoc --swift_out=Sources/DisassemblyRequest disassembly_request.proto

Sources/gbdis/disassembly_request.pb.swift: disassembly_request.proto
	protoc --swift_out=Sources/gbdis disassembly_request.proto
