# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

ARG VITE_AUTH_SERVICE_URL=https://auth.institutoitinerante.com.br
ARG VITE_API_URL=https://contracts.institutoitinerante.com.br
ENV VITE_AUTH_SERVICE_URL=$VITE_AUTH_SERVICE_URL
ENV VITE_API_URL=$VITE_API_URL

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including devDependencies for vite build)
RUN npm install

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
