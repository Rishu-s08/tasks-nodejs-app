FROM node:20

WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Install nodemon globally for development
RUN npm install -g nodemon ts-node

# Copy source code
COPY . .

EXPOSE 8000

# Use nodemon for development with polling for file changes
CMD ["nodemon", "--legacy-watch", "--poll-interval", "1000", "src/index.ts"]