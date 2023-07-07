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

##  Instruções de Execução
### Configurando instância EC2
- Acessar a AWS na pagina do serviço EC2, e clicar em "instancias" no menu lateral esquerdo.
- Clicar em "executar instâncias" na parte superior esquerda da tela.
- Abaixo do campo de inserir nome clicar em "adicionar mais tags".
- Crie e insira o valor para as chaves: Name, Project e CostCenter, selecionando "intancias", "volume" e "interface de rede" como tipos de recurso e adicionando os valores de sua preferencia.
- Abaixo selecione também a AMI Amazon Linux 2(HVM) SSD Volume Type.
- Selecionar como tipo de intância a família t3.small.
- Em Par de chaves login clique em "criar novo par de chaves".
- Insira o nome do par de chaves, tipo RSA, formato .ppk e clique em "criar par de chaves".
- Em configurações de rede, selecione criar grupo de segurança e permitir todos tráfegos(SSH).
- Configure o armazenamento com 16GiB, volume raiz gp2.
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
  
