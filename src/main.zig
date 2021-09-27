const std = @import("std");
const Listener = std.x.net.tcp.Listener;
const Domain = std.x.net.tcp.Domain;
const Address = std.x.net.ip.Address;
const IPv4 = std.x.os.IPv4;
const Socket = std.x.os.Socket;
const Buffer = std.x.os.Buffer;
const Connection = std.x.net.tcp.Connection;
const sleep = std.time.sleep;

fn handle_connection(connection : *Connection) !void {
    defer connection.deinit();

    const message = "hello world";
        
    while(true) {
        _ = try connection.client.write(message, 0);
        suspend {
            std.time.sleep(1000000000);
            resume @frame();
        }
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello, {s}!\n", .{"world"});

    var listener = try Listener.init(Domain.ip, .{ .close_on_exec = true });
    defer listener.deinit();
    
    var frames : [2]@Frame(handle_connection) = undefined;
    var index : usize = 0;

    try listener.bind(Address.initIPv4(IPv4.unspecified, 22));
    try listener.listen(128);
    while(true) {
        var connection = try listener.accept(.{ .nonblocking = true });
        frames[index] = async handle_connection(&connection);
        index += 1;
    }
    
}