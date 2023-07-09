# Atividade AWS docker

## Requisitos
- Instalação e configuração do DOCKER ou CONTAINERD no host EC2;
- Ponto adicional para o trabalho utilizar a instalação via script de Start Instance (user_data.sh)
- Efetuar Deploy de uma aplicação Wordpress com: 
  - Container de aplicação
  - Container database Mysql
  - Configuração da utilização do serviço EFS AWS para estáticos do container de aplicação Wordpress
  - Configuração do serviço de Load Balancer AWS para a aplicação Wordpress

## Pontos de atenção
- Não utilizar ip público para saída do serviços WP (Evitar publicar o serviço WP via IP Público)
- Sugestão para o tráfego de internet sair pelo LB (Load Balancer Classic)
- Pastas públicas e estáticos do wordpress sugestão de utilizar o EFS (Elastic File Sistem)
- Fica a critério de cada integrante usar Dockerfile ou Dockercompose;
- Necessário demonstrar a aplicação wordpress funcionando (tela de login)
- Aplicação Wordpress precisa estar rodando na porta 80 ou 8080;
- Utilizar repositório git para versionamento;
- Criar documentação


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


##  Instruções de Execução
### Configurando instância EC2
- Acessar a AWS na pagina do serviço EC2, e clicar em "instancias" no menu lateral esquerdo.
- Clicar em "executar instâncias" na parte superior esquerda da tela.
- Abaixo do campo de inserir nome clicar em "adicionar mais tags".
- Crie e insira o valor para as chaves: Name, Project e CostCenter, selecionando "intancias", "volume" e "interface de rede" como tipos de recurso e adicionando os valores de sua preferencia.
- Abaixo selecione também a AMI Amazon Linux 2(HVM) SSD Volume Type.
- Selecionar como tipo de intância a família t3.small.
- Em Par de chaves login clique em "criar novo par de chaves".
- Insira o nome do par de chaves.
- Em configurações de rede, selecione criar grupo de segurança e permitir todos tráfegos(SSH).
- Configure o armazenamento com 16GiB, volume raiz gp2.
- Em configurações avançadas insira esse script
  
```
#!/bin/bash
yum update
yum install -y docker
systemctl start docker
systemctl enable docker
gpasswd -a ec2-user docker

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

- Clique em executar instância.


### Editar grupo de segurança liberando as portas de comunicação para acesso
- Na pagina do serviço EC2, no menu lateral esquerdo ir em "Rede e Segurança" e clicar em "Security groups".
- Selecionar o grupo criado anteriormente junto com a instancia.
- Clicar em "Regras de entrada" e do lado esquerdo da tela em "Editar regras de entrada".
- Defina as regras como na tabela abaixo:

    Tipo | Protocolo | Intervalo de portas | Origem | Descrição
    ---|---|---|---|---
    SSH | TCP | 22 | 0.0.0.0/0 | SSH
    TCP personalizado | TCP | 80 | 0.0.0.0/0 | HTTP
    TCP personalizado | TCP | 2049 | 0.0.0.0/0 | NFS
    MYSQL/Aurora | TCP | 3306 | 0.0.0.0/0 | RDS

- Clicar em "Salvar regras".


### EFS
Crie um Security group para o EFS.
- Clique em criar grupo de segurança, este será utilizado para segurança de rede do EFS.
- Depois de atribuir um nome, adicione como regra de entrada o NFS com origem para o grupo de segurança criado e anexado anteriormente junto da instancia.
Deverá ficar assim:
    Tipo | Protocolo | Intervalo de portas | Origem | Descrição
    ---|---|---|---|---
    NFS | TCP | 2049 | sg-instancia | NFS

- Clique em criar grupo de segurança para finalizar.


### Criando Elastic File System
- Ainda no ambiente da AWS, navegue até o serviço de EFS.
- No menu lateral esquerdo clique em Sistemas de arquivos e logo após em "Criar sistema de arquivos" a direita.
- Adicione um nome e selecione a opção "personalizar".
- Marque a opção "One Zone" e selecione a zona de disponibilidade na qual criou sua instancia.
- Mantenha o restante, só altere o grupo de segurança para o criado anteriormente.
- Clique em criar para finalizar.
- Abra o sistema de arquivos criado e clique no botão "anexar" a esquerda para visualizar as opções de montagem(IP ou DNS).

```
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-069b6cb64a852692f.efs.us-east-1.amazonaws.com:/ efs
```

- Na instancia monte o diretória onde será montado o efs.

```
sudo mkdir -p /mnt/efs/wordpress
```

- Cole o comando do efs no console trocando o diretório e use o "df -h" para ver se foi montado corretamente.
```
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-069b6cb64a852692f.efs.us-east-1.amazonaws.com:/ /mnt/nfs
df -h
```


## Criando RDS(MySQL)
- Acesse o serviço RDS na sua conta AWS, no canto lateral esquerdo clique em "Banco de dados".
- Clique no botão laranja no canto superior direito em "Criar banco de dados".
- Selecione o métode de "criação fácil "e "MySQL" como banco de configuração.
- Selecione também o "nível gratuito" e preencha as credenciais do banco como na imagem.
- Por último clique em "criar banco de dados" no canto inferior da tela e aguarde a criação, isso pode levar alguns minutos.


### Subindo container docker
- Com o docker e o docker compose ja instalados pelo 'user-data.sh' nós iremos criar um 'docker-compose.yml' para subir o container com WordPress + Banco de Dados RDS.
- Use o comando para criar o arquivo:
```
  sudo nano docker-compose.yml
```
- Adicione essas linhas ao docker compose (alterando pelos seus dados):

```
version: '3'
services:
  wordpress:
    image: wordpress:latest
    volumes:
      - /mnt/efs/wordpress:/var/www/html
    restart: always
    ports:
      - 80:80
    environment:
      WORDPRESS_DB_HOST: database-pb2.cpy1vk3kgfvg.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: adminpb
      WORDPRESS_DB_PASSWORD: teste123
      WORDPRESS_DB_NAME: database-pb2
```
- Para executar o arquivo e subir o container com Wordpress conectado ao banco MySQL execute o comando:
```
docker-compose up -d
```
- Para testar se o container está rodando execute:
```
docker ps
```

## Criando um Load Balancer
- Acesse o serviço EC2 da AWS, em Load Balancers e vá em "Criar Load Balancer".
- Escolha um nome e deixe todas a opções padrões além do vpc.
- Iremos utilizar o VPC usado anteriormente e selecionar todas as zonas de disponibilidade disponiveis nele.


## Criar uma AMI
- Acesse o serviço EC2 da AWS, em instancias selecione a que subimos o container com WordPress e as demais configurações.
- No canto superior direito clique em "Ações" > "imagem e modelos" > "criar imagem".
- Insira um nome e descrição, observe que ela já pega as configurações pré-definidas da instancia que vamos utilizar como modelo, na qual fizemos todas configurações até agora.
- Mantenha as opções padrão e clique em "criar imagem" para concluir.

## Criar o Auto Scaling Group
  ### **Parte 1** 
- Insira um nome e no canto superior da opção de modelo de execução clique em "Alterar para configuração de execução".
- Abaixo aparecerá a opção de selecionar uma configuração de execução já existente ou criar uma nova, neste caso vamos criar pois não temos nenhuma.
- Preencha o campo de nome e selecione a AMI criada anteriormente.
- Escolha o tipo de instancia "t2.micro(1 vCPUs, 1 GiB, Somente EBS)".
- Mantenha as demais configurações pré-definidas, em Grupos de segurança selecione o que foi criado e anexado anteriormente a instancia.
- Escolha um par de chaves, o mesmo anexado a instancia ao criá-la.
- Marque a caixinha: "Confirmo que tenho acesso ao arquivo de chave privada selecionado e que, sem esse arquivo, não poderei fazer login na minha instância".
- Clique em "criar configuração de execução".
- Voltando ao processo de criação do Auto Scaling Group recarregue as opções de configuração de execução e selecione a que acabamos de criar.
- Clique em "próximo" no canto inferior direito.

### **Etapa 2** 
- Mantenha a VPC utilizada anteriormente e selecione todas as zonas de disponibilade.
- Clique em "próximo" no canto inferior direito.

### **Etapa 3**
- Selecione o Load Balancer criado anteriormente.
- Mantenha as outras opções padrões.
- Clique em "próximo".

### **Etapa 4**
- Tamanho do grupo, aqui vamos especificar o tamanho do grupo do Auto Scaling alterando a capacidade desejada. Você também pode especificar os limites de capacidade mínima e máxima. Sua capacidade desejada deve estar dentro do intervalo dos limites. Neste caso vamos configurar de acordo com o que a atividade pede(Capacidade desejada: 2, Capacidade mínima: 2, Capacidade máxima: 2).
- Mantenha o restante das configurações pré-definidas pela aws e clique em "próximo".

### **Etapa 5**
- Apenas ignore essa parte no momento.

### **Etapa 6**
- Adicione uma TAG "Name" "PB - Senac WORDP", para as instancias ja subirem com esse nome e ter uma organização melhor.
