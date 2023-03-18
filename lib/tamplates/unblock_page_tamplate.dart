///
String generateUnblockPage() {
  return '''
<!DOCTYPE HTML>
<html>
   <head>
      <title>Учетная запись разблокирована</title>
   </head>
   <body>
      <h1>Аккаунт разблокирован</h1>
      <p>Ваша учетная запись успешно разблокирована.</p>
   </body>
</html>
''';
}

///
String generateUnblockErrorPage() {
  return '''
<!DOCTYPE HTML>
<html>
   <head>
      <title>Ссылка не действительна</title>
   </head>
   <body>
      <h1>Ссылка не действительна</h1>
      <p>Ссылка по которой вы прошли уже была использована или её время истекло.</p>
   </body>
</html>
''';
}
