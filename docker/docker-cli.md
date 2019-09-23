## docker常用命令

Docker镜像是由Dockerfile和一些必要的依赖项组成的，Docker容器是动态的Docker镜像。要使用Docker命令，首先需要知道您是在处理镜像还是容器。一旦你知道你所处理的是镜像还是容器之后，你才可以找到正确的命令。


你需要知道一些关于Docker命令的规律：

- Docker CLI管理命令以docker开头，然后是空格，接着是管理类别，然后是空格最后是命令。例如，docker container stop这一命令可以停止容器。
- 引用特定容器或镜像的命令需要该容器或镜像的名称或ID。

举个例子，docker container run my_app 是用于构建和运行名为*my_app*的容器的命令。在本文示例中，我将使用名称my_container来引用通用容器。同理，my_image、my_tag也是如此。

我将单独提供命令和通用标志。前面有两个破折号的标志是标志的全名。带有一个破折号的标志是完整标志名称的缩写。例如，-p是--port标志的缩写。

本文的目标是让您牢牢记住这些命令和标记，并希望您可以在创建容器或构建镜像的时候可以将本指南作为参考。本指南适用于Linux和Docker Engine版本18.09.1以及API版本1.39。

我们先了解容器命令然后再看镜像命令。

**容器命令**

使用 docker container my_command

- create — 从镜像中创建一个容器
- start — 启动一个已有的容器
- run — 创建一个新的容器并且启动它
- ls — 列出正在运行的容器
- inspect — 查看关于容器的信息
- logs — 打印日志
- stop — 优雅停止正在运行的容器
- kill — 立即停止容器中的主要进程
- rm — 删除已经停止的容器



**镜像命令**

使用 docker image my_command

- build — 构建一个镜像
- push — 将镜像推送到远程镜像仓库中
- ls — 列出镜像
- history — 查看中间镜像信息
- inspect — 查看关于镜像的信息，包括层
- rm — 删除镜像



**容器&镜像**

- docker version — 列出关于Docker客户端以及服务器版本的信息
- docker login — 登录到Docker镜像仓库
- docker system prune — 删除所有未使用的容器、网络以及无名称的镜像（虚悬镜像）

