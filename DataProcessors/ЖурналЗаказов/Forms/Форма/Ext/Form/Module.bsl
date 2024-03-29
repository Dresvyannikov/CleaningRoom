﻿&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Дата = ТекущаяДата();   
	СоздатьИзмеренияПланировщика();
	ОбновитьПериодОтображенияПланировщика();  
	ЗаполнитьЖурналЗаписей();
КонецПроцедуры

Процедура ЗаполнитьЖурналЗаписей()   
	
	Планировщик.Элементы.Очистить();
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Заказы.Ссылка КАК Ссылка,
		|	Заказы.ВерсияДанных КАК ВерсияДанных,
		|	Заказы.ПометкаУдаления КАК ПометкаУдаления,
		|	Заказы.Номер КАК Номер,
		|	Заказы.Дата КАК Дата,
		|	Заказы.Проведен КАК Проведен,
		|	Заказы.ФИОЗаказчика КАК ФИОЗаказчика,
		|	Заказы.Адрес КАК Адрес,
		|	Заказы.СтатусЗаказа КАК СтатусЗаказа,
		|	Заказы.ОбщаяСтоимость КАК ОбщаяСтоимость,
		|	Заказы.ПлощадьПомещения КАК ПлощадьПомещения,
		|	Заказы.ФИОСотрудника КАК ФИОСотрудника,
		|	Заказы.ВремяОкончанияЗаказа КАК ВремяОкончанияЗаказа,
		|	Заказы.СтатусСотрудника КАК СтатусСотрудника,
		|	Заказы.ФотоОтчета КАК ФотоОтчета
		|ИЗ
		|	Документ.Заказы КАК Заказы
		|ГДЕ
		|	Заказы.Дата >= &ДатаНачала
		|	И Заказы.Дата <= &ДатаОкончания";
	
	Запрос.УстановитьПараметр("ДатаНачала", НачалоДня(Дата));
	Запрос.УстановитьПараметр("ДатаОкончания", КонецДня(Дата));
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	ЖирныйШрифт = Новый Шрифт(,,Истина);
	Пока Выборка.Следующий() Цикл  
		ЗначенияИзмерений = Новый Соответствие;
		ЗначенияИзмерений.Вставить("Сотрудник", Выборка.ФИОСотрудника);
		МассивСтрок = Новый Массив;
		ПредставлениеКлиента = Строка(Выборка.ФИОЗаказчика);
		МассивСтрок.Добавить(Новый ФорматированнаяСтрока(ПредставлениеКлиента, ЖирныйШрифт));
		МассивСтрок.Добавить(Символы.ПС);
		МассивСтрок.Добавить(Выборка.Адрес);
		ЭлементПланировщика = Планировщик.Элементы.Добавить(Выборка.Дата, Выборка.ВремяОкончанияЗаказа);
		ЭлементПланировщика.ЗначенияИзмерений = Новый ФиксированноеСоответствие(ЗначенияИзмерений);
		ЭлементПланировщика.Значение = Выборка.Ссылка;
		ЭлементПланировщика.Текст = Новый ФорматированнаяСтрока(МассивСтрок);
		ЭлементПланировщика.ЦветФона = WebЦвета.Голубой;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура СоздатьИзмеренияПланировщика()
	
	Перем Выборка, ВыборкаДолжности, ЗначениеИзмерения, Измерение;
	
	Измерение = Планировщик.Измерения.Добавить("Сотрудник");
	
	Выборка = Справочники.Сотрудники.Выбрать();
	//ВыборкаДолжности = Справочники.Должности.Выбрать();
	Пока Выборка.Следующий() Цикл
		
		Если Выборка.ПометкаУдаления Тогда
			Продолжить;		
		КонецЕсли;
		
		//Если  Выборка.Должность.Наименование = "Тренер" Тогда  
			
			ЗначениеИзмерения = Измерение.Элементы.Добавить(Выборка.Ссылка);	
			ЗначениеИзмерения.Текст = Выборка.Наименование;// + Символы.ПС + Выборка.Должность;
			ЗначениеИзмерения.ЦветРамки = WebЦвета.Черный;
		//КонецЕсли;
	КонецЦикла;

КонецПроцедуры

&НаСервере
Процедура ОбновитьПериодОтображенияПланировщика()
	
	Начало = НачалоДня(Дата) + 7*3600;
	Конец  = НачалоДня(Дата) + 20*3600;
    Планировщик.ТекущиеПериодыОтображения.Очистить();
	Планировщик.ТекущиеПериодыОтображения.Добавить(Начало, Конец);
КонецПроцедуры

&НаКлиенте
Процедура ДатаПриИзменении(Элемент)
	ОбновитьПериодОтображенияПланировщика(); 
	ЗаполнитьЖурналЗаписей();
КонецПроцедуры

&НаКлиенте
Процедура ПланировщикПередСозданием(Элемент, Начало, Конец, ЗначенияИзмерений, Текст, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ЗначенияЗаполнения = Новый Структура;
	ЗначенияЗаполнения.Вставить("Дата", Начало);
	ЗначенияЗаполнения.Вставить("ДатаОкончания", Конец);
	ЗначенияЗаполнения.Вставить("Сотрудник", ЗначенияИзмерений["Сотрудник"]);
	
	СтруктураПараметров = Новый Структура("ЗначенияЗаполнения", ЗначенияЗаполнения) ;
	
	ОткрытьФорму("Документ.Заказы.ФормаОбъекта",СтруктураПараметров);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ИзменениеЗапись" Тогда
	
		ЗаполнитьЖурналЗаписей();
	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПланировщикПередНачаломРедактирования(Элемент, НовыйЭлемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ВыделенныеЭлементы = Элемент.ВыделенныеЭлементы;  
	
	ЭлементПланировщика = ВыделенныеЭлементы[0];
	
	СтруктураПараметров = Новый Структура("Ключ",ЭлементПланировщика.Значение);
	ОткрытьФорму("Документ.Заказы.ФормаОбъекта", СтруктураПараметров);
	
КонецПроцедуры

&НаКлиенте
Процедура ПланировщикПередУдалением(Элемент, Отказ)
	Отказ = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ПланировщикПриОкончанииРедактирования(Элемент, НовыйЭлемент, ОтменаРедактирования)
	ВыделенныеЭлементы = Элемент.ВыделенныеЭлементы;
	ЭлементПланировщика = ВыделенныеЭлементы[0];
	Ответ = Вопрос("Вы действительно хотите изменить заказ?",РежимДиалогаВопрос.ДаНет);
	Если Ответ = КодВозвратаДиалога.Нет Тогда 
		Возврат;
	КонецЕсли;
	
	ПроверитьПеремещение(ЭлементПланировщика.Начало,ЭлементПланировщика.Конец,ЭлементПланировщика.ЗначенияИзмерений.Получить("Сотрудник"),ЭлементПланировщика.Значение)
	//ЗначенияРеквизитов = Новый Структура;
	//ЗначенияРеквизитов.Вставить("Дата", ЭлементПланировщика.Начало);
	//ЗначенияРеквизитов.Вставить("ДатаОкончания", ЭлементПланировщика.Конец);
	//ЗначенияРеквизитов.Вставить("Сотрудник", ЭлементПланировщика.ЗначенияИзмерений["Сотрудник"]); 
	//Если ОбновитьДанныеЗаписи (ЭлементПланировщика.Значение, ЗначенияРеквизитов) Тогда
	//		
	//	ЗаполнитьЖурналЗаписей();
	//	Сообщить("На перенесенное время запись недоступна из-за ограничений абонемента");
	//	
	//КонецЕсли; 
КонецПроцедуры  

Процедура ПроверитьПеремещение(ДатаНач,ДатаКон,Сотрудник,Заказ)
	ЗакзазОбъект = Заказ.ПолучитьОбъект();
	ЗакзазОбъект.Дата = ДатаНач;
	ЗакзазОбъект.ВремяОкончанияЗаказа = ДатаКон;
	ЗакзазОбъект.ФИОСотрудника = Сотрудник;
	ЗакзазОбъект.Записать(РежимЗаписиДокумента.Проведение);
КонецПроцедуры

&НаСервере
Функция ОбновитьДанныеЗаписи(Запись, ЗначенияРеквизитов)	
	ОбъектЗаписи = Запись.ПолучитьОбъект(); 
	ОбъектЗаписи2 = Запись.ПолучитьОбъект();
	ЕстьИзменения = Ложь;   
	Для каждого Реквизит Из  ЗначенияРеквизитов Цикл 
		Если ОбъектЗаписи[Реквизит.Ключ] <> Реквизит.Значение Тогда
			ЕстьИзменения = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла; 
	Если ЕстьИзменения Тогда 
		
		//Получение Данных о времени допустимом действии абонемента
		ИнфаОПериодеДействия = ПолучитьИнформациюОПериодеДействияАбонемента(ОбъектЗаписи.Абонемент); 
		ВремяНачала = ИнфаОПериодеДействия.ВремяНачалаДействия;
		ВремяОкончания = ИнфаОПериодеДействия.ВремяОкончанияДействия;  
		ТекущаяДатаНаНачалоДня = НачалоДня(ЗначенияРеквизитов.Дата); 
		ДопустимаяДатаНачала = ТекущаяДатаНаНачалоДня + (ВремяНачала - Дата(1,1,1));
		ДопустимаяДатаОкончания = ТекущаяДатаНаНачалоДня + (ВремяОкончания - Дата(1,1,1)); 
		
		//Проверка На Допустимость Времени в соответствии с абонементом		
		Если Не(ВремяНачала = '00010101' и ВремяОкончания = '00010101')	Тогда
			Если ЗначенияРеквизитов.ДатаОкончания > ДопустимаяДатаОкончания или ЗначенияРеквизитов.Дата < ДопустимаяДатаНачала  Тогда  
				Возврат Истина; 
			КонецЕсли;
		Иначе 
			//Присвоение документу новых значений во время изменения Объекта записи в планировщике с записью
			ЗаполнитьЗначенияСвойств(ОбъектЗаписи, ЗначенияРеквизитов);
			ОбъектЗаписи.Длительность = (ОбъектЗаписи.ДатаОкончания - ОбъектЗаписи.Дата) / 60;
			ОбъектЗаписи.Записать(РежимЗаписиДокумента.Проведение);
			Возврат Ложь; 
			
		КонецЕсли; 
	КонецЕсли;
	Возврат Ложь;
	
КонецФункции  

&НаСервере
Функция ПолучитьИнформациюОПериодеДействияАбонемента(Абонемент)

	Результат = Новый Структура("ВремяНачалаДействия,ВремяОкончанияДействия ", 0,0);
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВидыАбонементов.ВремяНачалаДействия КАК ВремяНачалаДействия,
		|	ВидыАбонементов.ВремяОкончанияДействия КАК ВремяОкончанияДействия
		|ИЗ
		|	Справочник.ВидыАбонементов КАК ВидыАбонементов
		|ГДЕ
		|	ВидыАбонементов.Ссылка = &Абонемент";
	
	Запрос.УстановитьПараметр("Абонемент", Абонемент);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если Не РезультатЗапроса.Пустой()Тогда
		
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		ЗаполнитьЗначенияСвойств(Результат, Выборка);
	
	КонецЕсли;
	Возврат Результат;
КонецФункции


&НаКлиенте
Процедура ПланировщикНачалоПеретаскивания(Элемент, ПараметрыПеретаскивания, Выполнение)
	Отказ = Истина;
КонецПроцедуры


&НаКлиенте
Процедура ПланировщикПеретаскивание(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Дата, ЗначенияИзмерений)
	Отказ = Истина;
КонецПроцедуры


&НаКлиенте
Процедура ПланировщикПроверкаПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Дата, ЗначенияИзмерений)
	
КонецПроцедуры

