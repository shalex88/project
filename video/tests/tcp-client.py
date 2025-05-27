import sys
import socket

def tcp_client(host, port, input_message ):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((host, port))
        print(f"[TCP Client] Connected to {host}:{port}")

        if input_message is None:
            try:
                while True:
                    message = input("[TCP Client] Enter message: ")
                    s.sendall(message.encode())

                    ascii_values = [ord(char) for char in message]
                    print(f'[TCP Client] Sent ({len(message)} bytes): "{message}" [{str(" ".join(map(str, ascii_values)))}]')

                    # Wait to receive echo back (optional, depends on your use case)
                    data = s.recv(1024)
                    data_list = list(data)
                    print(f'[TCP Client] Received ({len(data)} bytes): "{data.decode()}" [{" ".join(map(str, data_list))}]')

            except KeyboardInterrupt:
                print("\n[TCP Client] Shutting down")
        else:
            message = str(input_message)
            s.sendall(message.encode())

            ascii_values = [ord(char) for char in message]
            print(f'[TCP Client] Sent ({len(message)} bytes): "{message}" [{str(" ".join(map(str, ascii_values)))}]')

            # Wait to receive echo back (optional, depends on your use case)
            data = s.recv(1024)
            data_list = list(data)
            print(f'[TCP Client] Received ({len(data)} bytes): "{data.decode()}" [{" ".join(map(str, data_list))}]')


if __name__ == "__main__":
    if len(sys.argv) > 1:
        HOST = sys.argv[1]
    else:
        HOST = socket.gethostbyname(socket.gethostname())
        print(f"[TCP Client] Using default host: {HOST}")

    if len(sys.argv) > 2:
        PORT = int(sys.argv[2])
    else:
        PORT = 12345


    if len(sys.argv) > 3:
        input_message = sys.argv[3]
    else:
        input_message = None

    tcp_client(HOST, PORT, input_message)