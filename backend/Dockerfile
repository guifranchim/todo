# Escolher a imagem base do Node
FROM node:16

# Definir o diretório de trabalho no container
WORKDIR /app

# Copiar arquivos package.json e package-lock.json
COPY package*.json ./

# Instalar dependências
RUN npm install

# Copiar o restante dos arquivos
COPY . .

# Expor a porta do servidor
EXPOSE 3000

# Rodar a aplicação
CMD ["npm", "start"]
