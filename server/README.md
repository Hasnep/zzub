# Server

A high-level overview of the networking for Zzub.

```mermaid
flowchart LR
    subgraph Server
        http_server[HTTP server]
        server_ws[Websocket server]
    end
    http_server --> react_app
    subgraph Phone
        react_app[React app]
        phone_ws[Websocket client]
    end
    phone_ws <--> server_ws
    subgraph Game
        game_ws[Websocket client]
    end
    server_ws --> game_ws
```
