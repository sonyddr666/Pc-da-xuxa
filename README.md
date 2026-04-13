# 🖥️ Pc-da-xuxa: O Workspace que não deveria existir

Bem-vindo ao **Pc-da-xuxa**, um projeto que prova que se você colocar um motor de Ferrari num Uno Mille, ele voa (ou explode, o que vier primeiro). Isso aqui não é apenas um container Docker; é um ecossistema completo de sobrevivência dev dentro de um Ubuntu 24.04.

Se você já sentiu que seu computador atual é um "fantasma tentando existir em 720p", esse workspace veio pra te dar a energia de um Senior que toma café puro e debuga em produção.

---

## 🚀 O que tem nessa Nave? (Aura Stack)

A gente não economizou no `apt-get install`. Se existe, a gente instalou:

* **⚡ Ambiente Gráfico:** XFCE4 pra quem gosta de estabilidade e não quer que o servidor decole.
* **🌐 Browsers:** Brave (pra bloquear os anúncios da vida) e Firefox (o clássico imortal).
* **💻 Desenvolvimento:** VS Code, Node.js v20 e Java 21 (porque a gente é poliglota, mano).
* **🗄️ Banco de Dados:** DBeaver CE (pra olhar pro seu SQL e chorar com estilo).
* **💼 Escritório & Lazer:** OnlyOffice pra fingir produtividade e VLC/OBS Studio pra quando a vibe de influencer bater.

---

## 🛠️ Como dar vida ao Monstro

Este projeto foi forjado para rodar no **Coolify**, mas se você tiver coragem e o Docker instalado, o comando é aquele clássico:

```bash
# Clone o caos
git clone [https://github.com/sonyddr666/Pc-da-xuxa.git](https://github.com/sonyddr666/Pc-da-xuxa.git)

# Build que demora mais que o download de um jogo de 50GB
docker build -t pc-da-xuxa .

# Rodando e rezando
docker run -p 8080:8080 pc-da-xuxa
