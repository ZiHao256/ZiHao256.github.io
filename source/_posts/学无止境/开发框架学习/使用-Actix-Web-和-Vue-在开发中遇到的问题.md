---
title: 基于Actix-Web(Rust)和Vue的Web开发记录
toc: true
categories:
  - 学无止境
  - 开发框架学习
tags:
  - Rust
  - Actix-web
  - Vue
abbrlink: d028ccc3
date: 2023-11-13 21:42:48
---
# 后端（基于actix-web）

## login

- [x] 登录后，使用session存储用户的相关信息用于导出功能
- [x] 登录后，生成token返回给前端作为信息认证

## register

- [x] 注册后转到登录界面



## Home

### export & export_in_db

- [x] 用户使用该功能时，需要在请求header中传回`token`来认证

  - [x] **bug**:

    ```
    GET http://localhost:8080/export/x x x 401 (Unauthorized)
    ```

  - [x] **分析**：授权问题

  - [x] **solution**：`logger` + `debug`

    - 发现是 `actix-session`中设置的内容并没有在后续操作被访问，

      - 因为在`postman`中，`actix-session`返回的`set-cookie`会默认填充到`cookie`中

      - 而浏览器并没有这个功能，需要前端实现。

    - ~~这波是postman的锅~~

      - [x] **bug**：为了`actix-session`能够正常使用（需要将`actix-session`放置于响应头中的`set-cookie`，置于其他请求头中），需要使用`axios`的`axios.defaults.withCredentials = true`

        ```
        Access to XMLHttpRequest at 'http://localhost:8080/export/xxx' from origin 'http://localhost:5173' has been blocked by CORS policy: Response to preflight request doesn't pass access control check: The value of the 'Access-Control-Allow-Credentials' header in the response is '' which must be 'true' when the request's credentials mode is 'include'. The credentials mode of requests initiated by the XMLHttpRequest is controlled by the withCredentials attribute.
        ```

        - **分析：**仍然是跨域问题

          - 后端`axtix-session`不允许将`cookie`放置于跨域的响应头中
          - 为了确定权限，前端需要设置`withCredentials=true`：会默认将`cookie`放置于请求头中，但是实际上此时并没有`cookie`，因此会报错
          - 需要设置后端为`allow access allow origin`指定允许某个跨域请求的域名，便可以将`cookie`置于响应头中

        - **solution**：`actix-cors`

          1. 一种解法：
             1. 使用`Cors::allow_origin`来允许某个跨域源的请求
             2. 为了使得前端能够发出带认证的请求，例如`Vue中使用axios:withCredential`使得默认在请求头部加上后端发来的`set-cookie`，需要设置使用`Cors::support_credential`来支持
          2. 第二种解法：直接使用 [`Cors::permissive()`](https://docs.rs/actix-cors/latest/actix_cors/struct.Cors.html#method.permissive)梭哈，~~不当人了~~

          - refs:
            - [withCredentials——让我加了班](https://juejin.cn/post/7163597193058729998)
            - [examples/cors/backend/src/main.rs at master · actix/examples (github.com)](https://github.com/actix/examples/blob/master/cors/backend/src/main.rs)
            - [Cors in actix_cors - Rust (docs.rs)](https://docs.rs/actix-cors/latest/actix_cors/struct.Cors.html)

- [x] 导出query中`institute`对应的tuples

  - [x] **bug**：访问`export`的请求，无法进入`pub async fn get_arena_record`函数，会一直`await`
  - [x] **分析：**可能是`pool`的问题
  - [x] **Solution:** 需要将`SqlitePool`在`HttpServer::new`之前，以包裹在`web::Data`中来定义，因为`HttpServer::new`会对每个请求创建一个`Thread`，而`web::Data`内部使用了`Arc`保证并发安全
    - [x] ref：[Application | Actix](https://actix.rs/docs/application)

- [x] 创建`backend.db`和`其他系统.db`的多个连接池

  - [x] 每次对数据库操作时只需要使用一个连接即可

  - [x] > 实际上会自动从池子中分配连接
    > An asynchronous pool of SQLx database connections.
    >
    > Create a pool with [Pool::connect](https://docs.rs/sqlx-core/0.7.2/sqlx_core/pool/struct.Pool.html#method.connect) or [Pool::connect_with](https://docs.rs/sqlx-core/0.7.2/sqlx_core/pool/struct.Pool.html#method.connect_with) and then call [Pool::acquire](https://docs.rs/sqlx-core/0.7.2/sqlx_core/pool/struct.Pool.html#method.acquire) to get a connection from the pool; when the connection is dropped it will return to the pool so it can be reused.
    >
    > You can also pass `&Pool` directly anywhere an `Executor` is required; this will automatically checkout a connection for you.
    >
    > See [the module documentation](https://docs.rs/sqlx-core/0.7.2/sqlx_core/pool/index.html) for examples.

- [ ] SQLite 是一种嵌入式数据库，通常以文件形式存储在本地。
  - [ ] 访问前：需要使用`scp`每次连接前确保从其他服务器下载到本地

## 优化

- [x] 通过解析前端传来的查询参数（Query param），选择处理不同系统的DB，对后端代码进行复用
  - [x] `axios`对于get方法有`params`+`actin-web`的`Query`
  - [x] 使用`let/match expression`来简化多种情况赋值的代码
- [x] 创建枚举类型来包裹DB，将错误处理提前到创建枚举，避免多处枚举时还需要处理其他情况
- [ ] 对前端Component进行复用

# 前端（基于Vue）

- [x] 将records使用表格展示
- [ ] 将records分页显示
- [x] 将内容进行排序
- [x] records以文件形式下载
  - [x] xlsx
  - [x] db
- [x] 前端发出带query params的Get 请求，不需要完全修改url，也方便后端对代码复用