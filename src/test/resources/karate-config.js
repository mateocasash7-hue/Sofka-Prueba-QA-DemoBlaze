// Configuración global de Karate: se ejecuta antes de cada feature.
function fn() {
  var config = {
    // URL base de la API de Demoblaze
    baseUrl: 'https://api.demoblaze.com',

    // El frontend de Demoblaze envía la contraseña en Base64 (UTF-8)
    // (el Java.type va dentro de la función porque Karate no conserva las variables de afuera)
    codificar: function (texto) {
      var Base64 = Java.type('java.util.Base64');
      var JString = Java.type('java.lang.String');
      return Base64.getEncoder().encodeToString(new JString(texto).getBytes('UTF-8'));
    },

    // Genera un usuario distinto en cada ejecución, porque el sitio es público
    usuarioUnico: function () {
      return 'karate_' + Date.now() + '_' + Math.floor(Math.random() * 100000);
    }
  };

  karate.configure('connectTimeout', 10000);
  karate.configure('readTimeout', 15000);
  return config;
}
