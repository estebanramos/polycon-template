# README

## Diferencias con la entrega anterior
Se mantuvo muy poca lógica con respecto a la entrega anterior. Los Modelos de Professional y Appointment están creados a partir de ActiveRecord. La funcionalidad que se copió fue la de exportar grillas.


## Gemas 
* Devise para la Autenticación.
* CanCanCan para la Autorización.

## Base datos
* Se utiliza sqlite3

## Modelo

* Professional representa un Profesional.
* Appointment representa un Turno.
* User representa un usuario dentro de la aplicación.

## Datos adicionales

* Las credenciales para base de datos son las predeteminadas creadas por Rails.
* El modelo de usuarios posee un campo "role", el cual es un string que detalla su rol dentro de la aplicación (admin, consulta o asistencia).
* Se usó scaffold para la generación de todos los formularios de CRUD, adaptando los mismos segun necesidad (ej: dropdown de Professional para Appointment).


## Correr aplicación
```
bundle install
rails db:create
rails db:migrate
rails server
```
