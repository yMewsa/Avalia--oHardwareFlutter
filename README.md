# App de Registro de Ponto com Geolocalização e Biometria

Aplicativo Flutter para registro de ponto de colaboradores com autenticação por e-mail/NIF e senha, autenticação biométrica com `local_auth`, geolocalização com `geolocator` e armazenamento de registros no Cloud Firestore.

## Objetivo

Este projeto foi desenvolvido para atender a uma avaliação somativa com foco em:

- autenticação segura via Firebase Auth;
- uso de biometria para acesso rápido;
- validação da localização em tempo real;
- bloqueio do registro de ponto quando o funcionário estiver fora do raio permitido;
- histórico de registros em um ambiente amigável e responsivo.

## Tecnologias utilizadas

- Flutter
- Dart
- Firebase Auth
- Cloud Firestore
- geolocator
- local_auth
- Provider
- Material 3

## Arquitetura adotada

A estrutura do projeto foi organizada em camadas para facilitar manutenção e evolução:

- `lib/models/`: modelos de domínio
- `lib/controllers/`: regras de negócio e estado da aplicação
- `lib/services/`: integrações com Firebase, localização e biometria
- `lib/views/`: telas e componentes visuais
- `lib/utils/`: rotas, helpers e utilidades
- `lib/core/`: constantes e tema visual

## Pré-requisitos

Antes de rodar o projeto, certifique-se de ter instalado:

1. Flutter SDK
2. Android Studio ou VS Code com extensão Flutter
3. Emulador Android configurado ou dispositivo físico conectado
4. Conta no Firebase

## Configuração do Firebase

### 1) Criar projeto no Firebase

1. Acesse o Firebase Console.
2. Crie um novo projeto.
3. Adicione um app Android ao projeto.
4. Registre o app com o package name do projeto, por exemplo:
   - `com.example.ponto_geolocalizacao_biometria`
5. Baixe o arquivo `google-services.json`.
6. Coloque o arquivo em:
   - `android/app/google-services.json`

### 2) Ativar Firebase Authentication

1. No painel do Firebase, vá em `Authentication`.
2. Ative o método de login por `E-mail/senha`.
3. Opcionalmente, configure usuários testáveis para autenticação local.

### 3) Ativar Cloud Firestore

1. Vá em `Firestore Database`.
2. Crie o banco de dados em modo de produção ou teste.
3. Configure as regras conforme a necessidade da avaliação.
4. Verifique se a coleção `attendance_registry` será usada para salvar os pontos.

### 4) Configurar FlutterFire

No projeto Flutter, o Firebase precisa ser inicializado no `main.dart`:

```dart
await Firebase.initializeApp();
```

As dependências devem estar presentes no `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.1.0
  firebase_auth: ^5.3.0
  cloud_firestore: ^5.0.0
  geolocator: ^13.0.0
  local_auth: ^2.3.0
  provider: ^6.0.0
```

## Permissões de hardware no Android

No arquivo `android/app/src/main/AndroidManifest.xml`, adicione:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

Para alguns dispositivos Android, pode ser útil incluir também:

```xml
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

## Execução local

Na raiz do projeto, execute:

```bash
flutter pub get
flutter run
```

Se estiver usando um emulador ou dispositivo físico conectado, o app será compilado e executado automaticamente.

## Fluxo funcional do app

### 1. Login
- O usuário informa e-mail/NIF e senha.
- O sistema realiza autenticação via Firebase Auth.
- Caso a biometria esteja disponível, o usuário também pode acessar diretamente pelo atalho de autenticação biométrica.

### 2. Geolocalização
- O app solicita permissão de localização.
- Obtém a posição atual do dispositivo via `geolocator`.
- Calcula a distância até as coordenadas da empresa.
- Verifica se está dentro do raio de 100 metros.

### 3. Registro de ponto
- Se a distância for menor ou igual a 100 metros, o ponto pode ser registrado.
- Os dados são gravados no Cloud Firestore com:
  - `userId`
  - `timestamp`
  - `latitude`
  - `longitude`
  - `isWithinRadius`

### 4. Histórico
- O app consulta os registros em ordem cronológica.
- Exibe o histórico para o usuário autenticado.

## Outline para o Relatório de Implementação

### 1. Descrição técnica e arquitetura

O projeto foi desenvolvido seguindo uma arquitetura modular em camadas, com separação de responsabilidades entre:

- `models`: representações dos dados e esquemas de persistência;
- `controllers`: lógica de autenticação e registro de ponto;
- `services`: comunicação com Firebase, biometria e GPS;
- `views`: interface do usuário;
- `core`: constantes e tema visual.

Essa separação melhora a manutenção, facilita a reutilização e torna o código mais testável.

### 2. Decisões de design de UI/UX

A interface foi desenhada com foco em:

- clareza visual;
- feedback imediato ao usuário;
- uso de Material 3;
- botões com estados visuais claros;
- mensagens amigáveis em casos de erro ou bloqueio;
- responsividade para uso em diferentes tamanhos de tela.

A tela de login prioriza simplicidade e rapidez. Já a tela principal destaca a distância até a empresa e o botão principal para o registro do ponto.

### 3. Cálculo do raio com geolocator e biometria

A validação de presença da empresa foi feita calculando a distância em metros entre a posição atual do usuário e as coordenadas fixas da empresa.

Esse cálculo é realizado com a API `Geolocator.distanceBetween`, que recebe:

- latitude atual;
- longitude atual;
- latitude da empresa;
- longitude da empresa.

Se a distância for menor ou igual a 100 metros, o registro é permitido; caso contrário, o funcionamento é bloqueado com uma mensagem de aviso.

A autenticação biométrica foi integrada com o pacote `local_auth`, que verifica se o dispositivo oferece suporte à biometria e, em seguida, solicita a autenticação por digital ou Face ID quando disponível.

### 4. Desafios encontrados e soluções aplicadas

#### Desafio 1: Permissões de hardware
A principal dificuldade foi garantir que o app solicitasse corretamente as permissões de localização e biometria do Android.

Solução:
- inclusão das permissões nativas no `AndroidManifest.xml`;
- tratamento de exceções para casos de permissão negada;
- mensagens amigáveis para orientar o usuário.

#### Desafio 2: Validação de distância em tempo real
A distância até a empresa precisa ser atualizada de forma confiável e apresentável para o usuário.

Solução:
- uso da API `getCurrentPosition()`;
- atualização periódica da localização na tela principal;
- mensagens visuais para indicar se está dentro ou fora do raio permitido.

#### Desafio 3: UX em cenários de erro
Erros como GPS desligado, biometria indisponível ou permissão negada podem gerar frustração no usuário.

Solução:
- mensagens personalizadas;
- feedback visual em botões e telas;
- bloqueio do registro de ponto com orientações claras para correção.

## Observações finais

Este projeto foi estruturado para ser escalável, modular e adequado para uma avaliação prática de desenvolvimento Flutter com integração de Firebase, geolocalização e biometria.

A solução atende às demandas principais da proposta e pode ser expandida para novas regras comerciais, relatórios estatísticos e autenticação mais avançada no futuro.

