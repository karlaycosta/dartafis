# Dartafis

**Dartafis** é uma biblioteca para extração e processamento de características de impressões digitais, desenvolvida em Dart.  
Este projeto é um **port da biblioteca [SourceAFIS](https://sourceafis.machinezoo.com/)**, adaptado para funcionar de forma nativa no ecossistema Dart e Flutter.

![Dart SDK](https://img.shields.io/badge/dart-3.0%2B-blue)
![License: MIT](https://img.shields.io/badge/license-MIT-green)

---

## ✨ Recursos

- ✅ Redimensionamento de imagens para 500 DPI  
- ✅ Equalização de histograma para melhorar contraste  
- ✅ Binarização (preto e branco) para separar cristas e vales  
- ✅ Extração de minúcias (bifurcações e terminações)  
- ✅ Filtragem de minúcias redundantes e ruidosas  
- ✅ Geração de templates biométricos (parcialmente compatível com ISO FMD)  
- 🚧 *Matching (comparação de templates)* em desenvolvimento  

---

## 📦 Pré-requisitos

- Dart SDK **3.0** ou superior  
- Familiaridade com manipulação de imagens e conceitos de biometria  

---

## 🚀 Instalação

Adicione o Dartafis ao seu projeto no `pubspec.yaml`:

```yaml
dependencies:
  dartafis:
    git:
      url: https://github.com/seu-usuario/dartafis.git
      ref: main
```
## Licença
Este projeto está licenciado sob os termos da licença MIT. Veja o arquivo [LICENSE](https://github.com/karlaycosta/dartafis/blob/main/LICENCE) para mais informações.