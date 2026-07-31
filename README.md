# Anacronistta Demo

[![Flutter CI](https://github.com/karamba121/anacronistta-demo/actions/workflows/flutter.yml/badge.svg?branch=main)](https://github.com/karamba121/anacronistta-demo/actions/workflows/flutter.yml)
[![Deploy](https://github.com/karamba121/anacronistta-demo/actions/workflows/deploy.yml/badge.svg?branch=main)](https://github.com/karamba121/anacronistta-demo/actions/workflows/deploy.yml)
![Status](https://img.shields.io/badge/status-demo%20funcional-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-stable-0175C2?logo=dart)
![Platforms](https://img.shields.io/badge/platforms-Web%20%7C%20Android%20%7C%20Windows-blue)
![License](https://img.shields.io/github/license/karamba121/anacronistta-demo)

O Anacronistta é uma aplicação simples para controle pessoal de ponto. O
objetivo desta versão é oferecer uma experiência direta para registrar a
jornada diária, acompanhar horas trabalhadas e manter uma escala semanal sem
depender de conexão com um servidor.

> [!IMPORTANT]
> Este repositório contém apenas uma versão demo, reduzida e intencionalmente
> simples. Ele não representa o produto completo. Uma solução maior, com mais
> recursos e preparada para outros cenários de uso, será disponibilizada
> separadamente em outro repositório.

## O que a demo contempla

- Registro dos pontos de uma jornada conforme os turnos configurados.
- Linha do tempo com entrada, pausas, retornos e saída.
- Cálculo das horas trabalhadas durante o dia.
- Indicação da carga horária prevista e do progresso da jornada.
- Configuração dos dias esperados de trabalho.
- Cadastro, edição e remoção de múltiplos turnos por dia.
- Resumo da semana atual com horas trabalhadas, horas previstas e saldo.
- Comparativo diário entre a jornada realizada e a meta configurada.
- Exportação de um relatório PDF com os pontos do mês anterior.
- Funcionamento offline com persistência local.
- Interface navegável sem login.

### Configuração inicial

Na primeira execução, a aplicação cria uma jornada comercial padrão de segunda
a sexta-feira, totalizando 7 horas por dia:

| Turno | Início | Término | Duração |
| --- | --- | --- | --- |
| 1 | 08:00 | 11:00 | 3 horas |
| 2 | 13:00 | 17:00 | 4 horas |

Sábado e domingo são inicialmente configurados como dias sem expediente. Todos
os dias e turnos podem ser alterados pelo módulo de configurações.

## Telas

### Hoje

Apresenta o tempo trabalhado no dia, a carga horária esperada, o progresso da
jornada e a sequência de pontos que ainda precisa ser registrada.

### Resumo

Consulta os registros locais e exibe os dados da semana corrente:

- total de horas trabalhadas;
- saldo acumulado até o dia atual;
- horas trabalhadas por dia;
- metas definidas nas configurações;
- quantidade de dias em que a jornada esperada foi cumprida.

Dias futuros permanecem visíveis, mas não são contabilizados antecipadamente
como saldo negativo.

### Configurações

Permite habilitar ou desabilitar dias de trabalho e organizar um ou mais turnos
para cada dia da semana. As alterações são persistidas localmente e refletidas
automaticamente nas telas Hoje e Resumo.

## Relatório mensal

A opção **Exportar pontos**, disponível no menu superior, gera um PDF referente
ao mês anterior. O relatório segue a identidade visual da aplicação e contém:

- usuário e período do relatório;
- total de horas trabalhadas e previstas;
- saldo de horas;
- quantidade de pontos registrados;
- detalhamento diário dos horários;
- indicação de jornadas completas, incompletas ou sem registros;
- paginação, cabeçalho e rodapé.

A jornada prevista no relatório é calculada usando a configuração atual, pois
esta demo não mantém um histórico das alterações de escala.

O salvamento respeita o comportamento de cada plataforma:

- **Web:** inicia o download pelo navegador.
- **Windows:** grava o arquivo na pasta Downloads, sem sobrescrever relatórios
  existentes.
- **Android:** abre o seletor de documentos do sistema para que o usuário escolha
  o destino.

## Persistência e funcionamento offline

Os pontos e as configurações de jornada são armazenados localmente com
[Drift](https://drift.simonbinder.eu/) e SQLite. Os dados ficam vinculados à
instalação e ao perfil local em que a aplicação é executada.

Não existe sincronização com nuvem, servidor externo ou compartilhamento de
dados entre dispositivos nesta versão.

## Arquitetura

O projeto utiliza Flutter Modular e mantém as responsabilidades separadas por
módulos, repositórios e serviços:

```text
lib/
├── app/
│   ├── modules/
│   │   ├── home/
│   │   ├── charts/
│   │   ├── settings/
│   │   └── start/
│   └── widgets/
├── config/
└── data/
    ├── local/
    ├── repositories/
    └── services/
```

Principais tecnologias:

- Flutter e Dart;
- Flutter Modular;
- Drift e SQLite;
- `timelines_plus`;
- `pdf`;
- APIs específicas para exportação na Web, Windows e Android.

## Executando o projeto

Com o Flutter configurado, instale as dependências:

```bash
flutter pub get
```

Execute na plataforma desejada:

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d <id-do-dispositivo-android>
```

Para verificar o projeto:

```bash
flutter analyze
flutter test
```

Builds suportados:

```bash
flutter build web
flutter build windows
flutter build apk
```

## Deploy gratuito no GitHub Pages

O projeto contém o workflow
`.github/workflows/deploy-pages.yml`, responsável por analisar, testar,
compilar e publicar automaticamente a versão Web no GitHub Pages.

O deploy é executado:

- a cada atualização enviada para a branch `master`;
- manualmente pela opção **Run workflow** na aba Actions.

O caminho base é calculado pelo próprio workflow. Assim, a publicação funciona
tanto em `usuario.github.io/nome-do-repositorio/` quanto em um repositório raiz
chamado `usuario.github.io`.

### Ativação inicial

1. Envie este projeto para a branch `master` do repositório público no GitHub.
2. No repositório, abra **Settings > Pages**.
3. Em **Build and deployment**, selecione **GitHub Actions** como fonte.
4. Abra a aba **Actions** e acompanhe o workflow
   **Deploy Flutter Web to GitHub Pages**.
5. Ao final, a URL publicada aparecerá no ambiente `github-pages` e na página
   de configurações do Pages.

Não é necessário manter uma branch `gh-pages`. O artefato estático é publicado
diretamente pelas Actions oficiais do GitHub.

## Limitações intencionais

Esta demo não possui:

- autenticação ou gestão de usuários;
- backend ou API remota;
- sincronização entre dispositivos;
- gestão de equipes ou empresas;
- aprovação e ajuste administrativo de pontos;
- histórico versionado das escalas;
- regras trabalhistas avançadas;
- mecanismos completos de segurança, auditoria e recuperação de dados.

Esses limites são intencionais. O foco deste código é demonstrar, de forma
simples e navegável, a experiência central de registrar e acompanhar uma
jornada de trabalho. O produto mais amplo será mantido em outro repositório,
com escopo e arquitetura próprios.
