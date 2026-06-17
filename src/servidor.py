#!/usr/bin/env python3
"""
Servidor de transferencia de texto
Ejecutar en Linux Mint
"""

import socket
import threading
import json
import time
from datetime import datetime
import os
import sys
import signal

class ServidorTexto:
    def __init__(self, host='0.0.0.0', port=5000):
        self.host = host
        self.port = port
        self.clientes = {}
        self.buffer = []
        self.running = True
        self.historial_file = os.path.expanduser('~/transfer_texto_historial.txt')
        
    def iniciar(self):
        """Inicia el servidor"""
        try:
            self.socket_servidor = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket_servidor.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.socket_servidor.bind((self.host, self.port))
            self.socket_servidor.listen(5)
            self.socket_servidor.settimeout(1.0)
            
            self.mostrar_banner()
            print(f"🟢 Servidor iniciado en {self.host}:{self.port}")
            print(f"📡 IP local: {self.obtener_ip_local()}")
            print("\n⏳ Esperando conexiones...")
            print("📋 Presiona Ctrl+C para salir\n")
            
            while self.running:
                try:
                    cliente_socket, direccion = self.socket_servidor.accept()
                    hilo = threading.Thread(target=self.manejar_cliente, 
                                          args=(cliente_socket, direccion))
                    hilo.daemon = True
                    hilo.start()
                    print(f"✅ Cliente conectado: {direccion[0]}:{direccion[1]}")
                except socket.timeout:
                    continue
                except Exception as e:
                    if self.running:
                        print(f"❌ Error: {e}")
                        
        except KeyboardInterrupt:
            print("\n⏹️ Interrupción recibida")
        except Exception as e:
            print(f"❌ Error al iniciar servidor: {e}")
        finally:
            self.cerrar()
            
    def manejar_cliente(self, cliente_socket, direccion):
        """Maneja la conexión de un cliente"""
        try:
            self.clientes[direccion] = cliente_socket
            
            while self.running:
                datos = cliente_socket.recv(4096).decode('utf-8')
                if not datos:
                    break
                    
                self.procesar_mensaje(datos, direccion)
                
        except Exception as e:
            pass
        finally:
            if direccion in self.clientes:
                del self.clientes[direccion]
            try:
                cliente_socket.close()
                print(f"⚠️ Cliente desconectado: {direccion[0]}:{direccion[1]}")
            except:
                pass
                
    def procesar_mensaje(self, mensaje, direccion):
        """Procesa y almacena el mensaje recibido"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        # Guardar en buffer
        entrada = {
            'timestamp': timestamp,
            'origen': f"{direccion[0]}:{direccion[1]}",
            'texto': mensaje,
            'tipo': 'recibido'
        }
        self.buffer.append(entrada)
        
        # Mostrar en consola
        print(f"\n📨 [{timestamp}] De {direccion[0]}:{direccion[1]}")
        print(f"📝 {mensaje}")
        print("-" * 50)
        
        # Guardar en archivo
        self.guardar_historial(mensaje, timestamp, direccion)
        
        # Enviar confirmación
        try:
            confirmacion = f"✅ Recibido: {mensaje[:50]}..."
            self.clientes[direccion].send(confirmacion.encode('utf-8'))
        except:
            pass
            
    def guardar_historial(self, mensaje, timestamp, direccion):
        """Guarda el mensaje en un archivo de historial"""
        try:
            with open(self.historial_file, 'a', encoding='utf-8') as f:
                f.write(f"[{timestamp}] De {direccion[0]}:{direccion[1]}\n")
                f.write(f"{mensaje}\n")
                f.write("-" * 50 + "\n")
        except:
            pass
            
    def obtener_ip_local(self):
        """Obtiene la IP local de la máquina"""
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except:
            return "127.0.0.1"
            
    def mostrar_banner(self):
        """Muestra el banner del servidor"""
        banner = """
╔══════════════════════════════════════════════╗
║     📡 TRANSFER TEXTO - SERVIDOR           ║
║     Transferencia de texto en red local      ║
╚══════════════════════════════════════════════╝
        """
        print(banner)
            
    def enviar_mensaje(self, mensaje, ip_destino=None):
        """Envía un mensaje a un cliente específico o a todos"""
        if not self.clientes:
            print("❌ No hay clientes conectados")
            return
            
        if ip_destino:
            for direccion, socket_cliente in self.clientes.items():
                if direccion[0] == ip_destino:
                    try:
                        socket_cliente.send(mensaje.encode('utf-8'))
                        print(f"✅ Mensaje enviado a {ip_destino}")
                        return
                    except:
                        print(f"❌ Error al enviar a {ip_destino}")
                        return
            print(f"❌ Cliente {ip_destino} no encontrado")
        else:
            for direccion, socket_cliente in self.clientes.items():
                try:
                    socket_cliente.send(mensaje.encode('utf-8'))
                except:
                    pass
            print(f"✅ Mensaje enviado a {len(self.clientes)} clientes")
            
    def mostrar_historial(self, n=10):
        """Muestra los últimos n mensajes"""
        if not self.buffer:
            print("📭 No hay mensajes en el historial")
            return
            
        print(f"\n📋 Últimos {min(n, len(self.buffer))} mensajes:")
        print("-" * 60)
        for entrada in self.buffer[-n:]:
            print(f"[{entrada['timestamp']}] {entrada['origen']}")
            print(f"{entrada['texto']}")
            print("-" * 60)
            
    def limpiar_buffer(self):
        """Limpia el buffer de mensajes"""
        self.buffer = []
        print("🧹 Buffer limpiado")
        
    def cerrar(self):
        """Cierra el servidor y todas las conexiones"""
        self.running = False
        for socket_cliente in self.clientes.values():
            try:
                socket_cliente.close()
            except:
                pass
        try:
            self.socket_servidor.close()
        except:
            pass
        print("\n🔴 Servidor cerrado")

def main():
    """Función principal"""
    servidor = ServidorTexto()
    
    # Manejar señal de interrupción
    def signal_handler(sig, frame):
        servidor.cerrar()
        sys.exit(0)
        
    signal.signal(signal.SIGINT, signal_handler)
    
    # Iniciar servidor en un hilo
    hilo_servidor = threading.Thread(target=servidor.iniciar)
    hilo_servidor.daemon = True
    hilo_servidor.start()
    
    try:
        while servidor.running:
            print("\n" + "=" * 50)
            print("📡 SERVIDOR DE TRANSFERENCIA DE TEXTO")
            print("=" * 50)
            print("1. 📤 Enviar mensaje a todos")
            print("2. 📤 Enviar mensaje a IP específica")
            print("3. 📋 Ver historial")
            print("4. 🧹 Limpiar buffer")
            print("5. 📊 Estado del servidor")
            print("6. 🔴 Cerrar servidor")
            print("=" * 50)
            
            opcion = input("🔹 Selecciona una opción: ").strip()
            
            if opcion == "1":
                mensaje = input("📝 Ingresa el mensaje a enviar: ")
                servidor.enviar_mensaje(mensaje)
            elif opcion == "2":
                ip = input("🌐 Ingresa la IP del cliente: ")
                mensaje = input("📝 Ingresa el mensaje: ")
                servidor.enviar_mensaje(mensaje, ip)
            elif opcion == "3":
                n = input("📊 ¿Cuántos mensajes mostrar? (default 10): ")
                n = int(n) if n.isdigit() else 10
                servidor.mostrar_historial(n)
            elif opcion == "4":
                servidor.limpiar_buffer()
            elif opcion == "5":
                print(f"\n📊 Estado del servidor:")
                print(f"   Clientes conectados: {len(servidor.clientes)}")
                print(f"   Mensajes en buffer: {len(servidor.buffer)}")
                if servidor.clientes:
                    print("   Clientes:")
                    for direccion in servidor.clientes.keys():
                        print(f"     - {direccion[0]}:{direccion[1]}")
            elif opcion == "6":
                servidor.cerrar()
                print("👋 Servidor cerrado. ¡Hasta luego!")
                break
            else:
                print("❌ Opción no válida")
                
    except KeyboardInterrupt:
        servidor.cerrar()
        print("\n👋 Servidor cerrado por el usuario")

if __name__ == "__main__":
    main()
