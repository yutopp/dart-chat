#import("ServerManager.dart");

void main()
{
  new ServerManager("127.0.0.1", 34543);
  print("Server Running.");
}
