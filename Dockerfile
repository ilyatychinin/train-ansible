FROM debian:bookworm-slim

# Отключаем интерактивный режим для apt
ENV DEBIAN_FRONTEND=noninteractive

# Устанавливаем SSH-сервер, Python и базовые утилиты
RUN apt-get update && apt-get install -y \
    openssh-server \
    python3 \
    python3-pip \
    sudo \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Создаем директорию для SSH
RUN mkdir /var/run/sshd

# Создаем пользователя ansible с sudo-правами
RUN useradd -m -s /bin/bash ansible && \
    echo "ansible:ansible" | chpasswd && \
    adduser ansible sudo && \
    echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Настраиваем SSH для входа по ключу
RUN mkdir -p /home/ansible/.ssh && \
    chmod 700 /home/ansible/.ssh && \
    chown ansible:ansible /home/ansible/.ssh

# Разрешаем root-вход по SSH (опционально, для тестов)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Открываем SSH-порт
EXPOSE 22

# Запускаем SSH-сервер
CMD ["/usr/sbin/sshd", "-D"]