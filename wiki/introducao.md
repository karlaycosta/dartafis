# 📘 Introdução

**Dartafis** é um port da biblioteca [SourceAFIS](https://sourceafis.machinezoo.com/) para o ecossistema Dart. O objetivo deste projeto é fornecer uma solução biométrica de código aberto totalmente funcional e acessível para aplicações Dart e Flutter, especialmente voltadas à verificação de identidade com impressões digitais.

## 🧬 O que é SourceAFIS?

[SourceAFIS](https://sourceafis.machinezoo.com/) é uma biblioteca de reconhecimento de impressões digitais amplamente utilizada, escrita originalmente em Java e C#. Ela é capaz de extrair minúcias e comparar templates para fins de autenticação e identificação, com forte aderência a padrões como ISO 19794-2 (FMD).

## 🎯 Objetivo do Dartafis

Dartafis adapta a lógica de processamento e extração de características do SourceAFIS para funcionar de forma nativa em Dart, mantendo a compatibilidade com os conceitos e estruturas originais, sempre que possível.

## 🔄 Diferenças em relação ao SourceAFIS

Embora a base conceitual venha do SourceAFIS, existem diferenças importantes:

| Aspecto                 | Dartafis                          | SourceAFIS                       |
|-------------------------|-----------------------------------|----------------------------------|
| Linguagem               | Dart                              | Java, C#                         |
| Processamento de imagem | Usa `package:image` (Dart)        | Usa bibliotecas nativas (Java/C#)|
| Templates               | Geração parcial de FMD ISO        | Suporte completo a FMD e matching |
| Matching (comparação)   | Ainda **não implementado**        | Totalmente implementado          |
| Otimizações             | Em progresso                      | Altamente otimizadas             |

> **Nota:** O Dartafis ainda está em desenvolvimento ativo. Algumas funcionalidades (como o algoritmo de matching) estão em fase de implementação.

## ✅ Público-alvo

- Desenvolvedores Dart/Flutter que precisam incorporar verificação por impressão digital em suas aplicações.
- Pesquisadores e estudantes interessados em biometria.
- Sistemas leves embarcados que exigem bibliotecas compactas e cross-platform.
