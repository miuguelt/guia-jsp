package com.sena.inventario.controlador;

import com.sena.inventario.dao.ProductoDAO;
import com.sena.inventario.modelo.Producto;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet para manejar las operaciones CRUD de Productos.
 * Procesa las peticiones GET y POST para listar, crear, editar y eliminar productos.
 */
@WebServlet({"/productos", "/ProductosServlet"})
public class ProductoServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(ProductoServlet.class.getName());
    private final ProductoDAO productoDAO = new ProductoDAO();
    
    /**
     * Maneja las peticiones GET.
     * Según el parámetro "accion", realiza diferentes operaciones:
     * - listar: Muestra todos los productos (por defecto)
     * - nuevo: Muestra formulario para crear producto
     * - editar: Muestra formulario para editar producto existente
     * - eliminar: Elimina un producto
     * - buscar: Busca productos por categoría
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        if (accion == null) {
            accion = "listar";
        }
        
        LOGGER.info("GET - Acción: " + accion);
        
        switch (accion) {
            case "nuevo" -> mostrarFormularioNuevo(request, response);
            case "editar" -> mostrarFormularioEditar(request, response);
            case "eliminar" -> eliminarProducto(request, response);
            case "buscar" -> buscarProductos(request, response);
            default -> listarProductos(request, response);
        }
    }
    
    /**
     * Maneja las peticiones POST.
     * Procesa el formulario para crear o actualizar productos.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        
        LOGGER.info("POST - Acción: " + accion);
        
        if ("guardar".equals(accion)) {
            guardarProducto(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/productos");
        }
    }
    
    /**
     * Lista todos los productos y los envía a la vista.
     */
    private void listarProductos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Producto> productos = productoDAO.listarTodos();
        request.setAttribute("productos", productos);
        request.setAttribute("totalProductos", productos.size());
        request.getRequestDispatcher("/productos/lista.jsp").forward(request, response);
    }
    
    /**
     * Muestra el formulario para crear un nuevo producto.
     */
    private void mostrarFormularioNuevo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setAttribute("modo", "crear");
        request.setAttribute("titulo", "Nuevo Producto");
        request.getRequestDispatcher("/productos/formulario.jsp").forward(request, response);
    }
    
    /**
     * Muestra el formulario para editar un producto existente.
     */
    private void mostrarFormularioEditar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Producto producto = productoDAO.buscarPorId(id);
        
        if (producto == null) {
            request.setAttribute("error", "Producto no encontrado");
            listarProductos(request, response);
            return;
        }
        
        request.setAttribute("producto", producto);
        request.setAttribute("modo", "editar");
        request.setAttribute("titulo", "Editar Producto");
        request.getRequestDispatcher("/productos/formulario.jsp").forward(request, response);
    }
    
    /**
     * Guarda un producto nuevo o actualiza uno existente.
     */
    private void guardarProducto(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        try {
            // Obtener parámetros del formulario
            String idStr = request.getParameter("id");
            String codigo = request.getParameter("codigo");
            String nombre = request.getParameter("nombre");
            String descripcion = request.getParameter("descripcion");
            String precioStr = request.getParameter("precio");
            String stockStr = request.getParameter("stock");
            String categoria = request.getParameter("categoria");
            String estadoStr = request.getParameter("estado");
            
            // Validar campos obligatorios
            if (codigo == null || codigo.trim().isEmpty() ||
                nombre == null || nombre.trim().isEmpty() ||
                precioStr == null || precioStr.trim().isEmpty() ||
                stockStr == null || stockStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + 
                    "/productos?accion=nuevo&error=campos_obligatorios");
                return;
            }
            
            // Convertir tipos de datos
            BigDecimal precio = new BigDecimal(precioStr.trim());
            int stock = Integer.parseInt(stockStr.trim());
            boolean estado = estadoStr != null && "on".equals(estadoStr);
            
            if (idStr == null || idStr.trim().isEmpty()) {
                // Crear nuevo producto
                Producto producto = new Producto(
                    codigo.trim(),
                    nombre.trim(),
                    descripcion != null ? descripcion.trim() : "",
                    precio,
                    stock,
                    categoria != null ? categoria.trim() : "General"
                );
                
                boolean exito = productoDAO.insertar(producto);
                LOGGER.info("Producto creado: " + (exito ? "éxito" : "fallo"));
                
            } else {
                // Actualizar producto existente
                int id = Integer.parseInt(idStr);
                Producto producto = new Producto(
                    id,
                    codigo.trim(),
                    nombre.trim(),
                    descripcion != null ? descripcion.trim() : "",
                    precio,
                    stock,
                    categoria != null ? categoria.trim() : "General",
                    estado
                );
                
                boolean exito = productoDAO.actualizar(producto);
                LOGGER.info("Producto actualizado: " + (exito ? "éxito" : "fallo"));
            }
            
            response.sendRedirect(request.getContextPath() + "/productos");
            
        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Error en formato de números", e);
            response.sendRedirect(request.getContextPath() + 
                "/productos?accion=nuevo&error=formato_invalido");
        }
    }
    
    /**
     * Elimina un producto por su ID.
     */
    private void eliminarProducto(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean exito = productoDAO.eliminar(id);
            LOGGER.info("Producto eliminado: " + (exito ? "éxito" : "fallo"));
            
        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Error al parsear ID de producto", e);
        }
        
        response.sendRedirect(request.getContextPath() + "/productos");
    }
    
    /**
     * Busca productos por categoría.
     */
    private void buscarProductos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String categoria = request.getParameter("categoria");
        List<Producto> productos;
        
        if (categoria != null && !categoria.trim().isEmpty()) {
            productos = productoDAO.listarPorCategoria(categoria.trim());
            request.setAttribute("categoriaBuscada", categoria);
        } else {
            productos = productoDAO.listarTodos();
        }
        
        request.setAttribute("productos", productos);
        request.setAttribute("totalProductos", productos.size());
        request.getRequestDispatcher("/productos/lista.jsp").forward(request, response);
    }
}
