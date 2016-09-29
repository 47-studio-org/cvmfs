/**
 * This file is part of the CernVM File System.
 */
#ifndef CVMFS_CACHE_TRANSPORT_H_
#define CVMFS_CACHE_TRANSPORT_H_

#include <stdint.h>

namespace google {
namespace protobuf {
class MessageLite;
}
}

/**
 * Sending and receiving with a file descriptor. Does _not_ take the ownership
 * of the file descriptor.
 */
class CacheTransport {
 public:
  /**
   * Version of the wire protocol.  The effective protocol version is negotiated
   * through the handshake.
   */
  static const unsigned char kProtocolVersion = 1;
  static const uint32_t kMaxMsgSize = (2 << 24) - 1;  // 24MB (3 bytes)

  explicit CacheTransport(int fd_connection);
  ~CacheTransport() { }

  void SendMsg(google::protobuf::MessageLite *msg);
  bool RecvMsg(google::protobuf::MessageLite *msg);

  int fd_connection() const { return fd_connection_; }

 private:
  const static unsigned kMaxStackAlloc = 128 * 1024;  // 128 kB

  void SendData(void *data, uint32_t size);
  bool RecvHeader(uint32_t *size);
  bool RecvRawMsg(void *buffer, uint32_t size);

  int fd_connection_;
};  // class CacheTransport

#endif  // CVMFS_CACHE_TRANSPORT_H_
