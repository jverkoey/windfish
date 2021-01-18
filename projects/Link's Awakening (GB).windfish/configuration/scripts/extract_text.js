function extractText(bank, startAddress, endAddress) {
  const data = getROMData(bank, startAddress, endAddress);
  let textStartAddress = startAddress;
  let textEndAddress = textStartAddress;
  let dataIndex = 0;
  // Consume text until we've evaluated all data
  while (textEndAddress < endAddress) {
    // Find the terminator for this text.
    while (data[dataIndex] != 0xFF && textEndAddress < endAddress) {
      dataIndex += 1;
      textEndAddress += 1;
    }
    registerText(bank, textStartAddress, textEndAddress, 16)
    if (textEndAddress < endAddress) {
      registerData(bank, textEndAddress, textEndAddress + 1)
    }
    textStartAddress = textEndAddress + 1;
    textEndAddress = textStartAddress;
    dataIndex += 1;  // Skip the terminator
  }
}

function disassemblyWillStart() {
  extractText(0x09, 0x6700, 0x6d9f);
}
