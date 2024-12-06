function sortArray(arr, sortBy) {
  if (!Array.isArray(arr)) {
    throw new Error("Первый аргумент должен быть массивом.");
  }

  if (!(sortBy === 'date_up' | sortBy === 'date_down' | sortBy === 'name')){
    throw new Error("Параметр сортировки должен быть 'date' или 'name'.");
  }

  return arr.sort(function (a, b) {
      var current_date = new Date();
      var arr_a = a.date.split(".");
      var dateA = new Date(arr_a[2], arr_a[1], arr_a[0]);
      var arr_b = b.date.split(".");
      var dateB = new Date(arr_b[2], arr_b[1], arr_b[0]);
      if (sortBy === 'date_down') {
      // Сортировка по дате
          return dateB - dateA;
      }
      else if (sortBy === 'date_up') {
          return dateA - dateB;
      }
      else if (sortBy === 'name') {
          // Сортировка по названию (лексикографически)
          return a.name.localeCompare(b.name);
    }
  });
}

function fullTextSearchAdvanced(array, search) {
    // Разделяем запрос на слова и создаем регулярное выражение
    var words = search.split(/\s+/).map(function (word) {word.toLowerCase()});
    var regex = new RegExp(words.join('|'), 'i'); // "Или" между словами

    return array.filter(function (item) {return regex.test(item.name)});
}

function fullTextSearch(array, search) {
    // Приводим запрос и элементы массива к нижнему регистру для нечувствительности к регистру
    var normalizedSearch = search.toLowerCase();
    var searchWords = normalizedSearch.split(/\s+/); // Разбиваем запрос на слова

    return array.filter(function (item) {
        var normalizedItem = item.name.toLowerCase(); // Приводим элемент массива к нижнему регистру
        // Проверяем, содержит ли элемент все слова из запроса
        return searchWords.every(function (word) {return normalizedItem.indexOf(word) !== -1});
    });
}

function get_d_m_y(form) {
    var arr = form.split(".");
    return {"day": Number(arr[0]),
            "month": Number(arr[1]),
            "year": Number(arr[2])
    }
}

function get_month(m, loc) {
    var months = ['Январь', "Февраль", "Март",
             "Апрель", "Май", "Июнь", "Июль",
             "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    return months[m-1]
}

function get_day_week(form) {
    var ru_days = ["Понедельник", "Вторник", "Среда", "Четверг",
                "Пятница", "Суббота", "Воскресенье"]
    var en_shortdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var ru_shortdays = ["пн", "вт", "ср", "чт", "пт", "сб", "вс"]
    var w = form.split(" ")[0]
    for (var i = 0; i<7; i++) {
        if (w === en_shortdays[i] | w === ru_shortdays[i]) {
            return ru_days[i]
        }
    }
    return false
}

function isValidDate(dateString) {
    var regex = /^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/
    if (!regex.test(dateString)) {
        return false; // Формат неверный
    }

    // Разбиваем строку на компоненты
    var splitdate = dateString.split('.').map(Number);
    var year, month, day;
    year = splitdate[2];
    month = splitdate[1];
    day = splitdate[0];

    // Проверяем корректность даты
    var date = new Date(year, month - 1, day); // Месяцы начинаются с 0

    // Проверяем, совпадают ли введенные значения с созданной датой
    return date.getFullYear() === year &&
           date.getMonth() === month - 1 &&
           date.getDate() === day;
}

function get_correct_month(m) {
    var months = ['января', "февраля", "марта",
             "апреля", "мая", "июня", "июля",
             "августа", "сентября", "октября", "ноября", "декабря"]
    return months[m-1]
}

function get_correct_date(d, m, y) {
    var dd, mm, yyyy
    if (d in ["1", "2", "3", "4", "5", "6", "7", '8', "9", "0"]) {
        dd = "0" + d
    } else {
        dd = d
    }
    if (m in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]) {
        mm = "0" + m
//        console.log("mm: " + mm)
    } else {
//        console.log("else m: " + m)
        mm = m
    }
    yyyy = y
//    console.log("in js: " + dd + "." + mm + "." + yyyy)
    return dd + "." + mm + "." + yyyy
}

function get_format_date(date) {
    var s = date.split(".")
    return s[0] + ' ' + get_correct_month(Number(s[1])) + " " + s[2] + "г."
}
