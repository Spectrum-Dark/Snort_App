# Configuración y Ejecución de Snort

Este README te guiará a través de la instalación y configuración básica de Snort para la detección de intrusiones. Es crucial prestar atención a las **ubicaciones de los directorios** para que los comandos funcionen correctamente.

---

## 1. Actualización de Repositorios y Instalación de Snort

Primero, necesitas agregar los repositorios adecuados y actualizar tu sistema para poder instalar Snort.

1.  **Edita el archivo `sources.list`:**

    ```bash
    sudo nano /etc/apt/sources.list
    ```

2.  **Agrega las siguientes líneas** al final del archivo. Asegúrate de incluir las arquitecturas `arm64` y `i386,amd64` según tu sistema:

    ```
    deb [arch=arm64] [http://ports.ubuntu.com/ubuntu-ports](http://ports.ubuntu.com/ubuntu-ports) focal main restricted universe multiverse
    deb [arch=arm64] [http://ports.ubuntu.com/ubuntu-ports](http://ports.ubuntu.com/ubuntu-ports) focal-updates main restricted universe multiverse
    deb [arch=arm64] [http://ports.ubuntu.com/ubuntu-ports](http://ports.ubuntu.com/ubuntu-ports) focal-security main restricted universe multiverse
    deb [arch=i386,amd64] [http://us.archive.ubuntu.com/ubuntu/](http://us.archive.ubuntu.com/ubuntu/) focal main restricted universe multiverse
    deb [arch=i386,amd64] [http://us.archive.ubuntu.com/ubuntu/](http://us.archive.ubuntu.com/ubuntu/) focal-updates main restricted universe multiverse
    deb [arch=i386,amd64] [http://security.ubuntu.com/ubuntu](http://security.ubuntu.com/ubuntu) focal-security main restricted universe multiverse
    ```

3.  **Guarda y cierra** el archivo (Ctrl+O, Enter, Ctrl+X).

4.  **Agrega las claves GPG** necesarias:

    ```bash
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C
    ```

5.  **Actualiza los índices de paquetes:**

    ```bash
    sudo apt update
    ```

6.  **Instala Snort:**

    ```bash
    sudo apt install snort
    ```

7.  **Verifica que los archivos de configuración existan:**

    ```bash
    ls /etc/snort/snort.conf
    ls /etc/snort/rules/local.rules
    ```

---

## 2. Crear una Regla Personalizada

Vamos a crear una regla sencilla para detectar pings (tráfico ICMP).

1.  **Edita el archivo `local.rules`:**

    ```bash
    sudo nano /etc/snort/rules/local.rules
    ```

2.  **Agrega la siguiente regla** al final del archivo:

    ```
    alert icmp any any -> any any (msg:"Ping detectado"; sid:1000001; rev:1;)
    ```

3.  **Guarda y cierra** el archivo.

---

## 3. Asegurarse de que `snort.conf` incluya `local.rules`

Para que Snort utilice tu regla personalizada, debe estar incluida en su configuración principal.

1.  **Abre el archivo de configuración de Snort:**

    ```bash
    sudo nano /etc/snort/snort.conf
    ```

2.  **Busca la línea** que incluye `local.rules`. Generalmente se encuentra al final del archivo:

    ```
    include $RULE_PATH/local.rules
    ```

    Si no la encuentras, **agrégala**.

3.  **Revisa la variable `HOME_NET`**. Al inicio del archivo, busca y **ajusta esta variable a la red de tu hogar o entorno** (ejemplo: `192.168.1.0/24`):

    ```
    ipvar HOME_NET 192.168.1.0/24
    ```

4.  **Guarda y cierra** el archivo.

---

## 4. Verificar tu Interfaz de Red

Necesitas saber qué interfaz de red está activa para que Snort pueda monitorearla.

1.  **Ejecuta el siguiente comando** para listar tus interfaces de red:

    ```bash
    ip a
    ```

2.  **Identifica tu interfaz de red activa** (por ejemplo, `eth0`, `enp0s3`, `wlan0`, etc.). Anótala, la usarás en el siguiente paso.

---

## 5. Ejecutar Snort

Ahora puedes iniciar Snort para que comience a monitorear el tráfico en la interfaz especificada.

1.  **Ejecuta Snort** con el siguiente comando:

    ```bash
    sudo snort -A console -q -c /etc/snort/snort.conf -i eth0
    ```

    **¡Importante!** Cambia `eth0` por el nombre de la interfaz de red que identificaste en el paso anterior.

---

## 6. Generar Tráfico para Probar

Para verificar que Snort está funcionando correctamente, genera algo de tráfico de red, como un ping.

1.  **Desde otra terminal o máquina**, haz un ping a la dirección IP de tu máquina virtual (donde Snort está corriendo):

    ```bash
    ping <ip_de_tu_vm>
    ```

2.  **Si todo está configurado correctamente**, deberías ver un mensaje similar a este en la consola donde Snort está ejecutándose:

    ```
    [**] [1:1000001:1] Ping detectado [**]
    ```

¡Felicidades! Has configurado y probado Snort para detectar pings. Puedes expandir tus reglas para detectar otro tipo de tráfico o actividades maliciosas.