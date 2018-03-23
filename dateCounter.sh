#!/bin/bash
#Krzysztof Krzyzek, 2017

function helper {
	printf "@@@ HELP @@@\n";
	printf "**********************************************************\n";
	printf "@@@ Krzysztof Krzyzek - 2017 @@@\nODLICZANIE CZASU DO DATY\n";
	printf "**********************************************************\n";
	printf "*Skrypt sluzy do odliczania czasu od biezacego momentu do wprowadzonej przez uzytkownika daty. Skrypt samodokumentuje sie przy wywolaniu z argumentami -h/--h.\nAby uruchomic skrypt nalezy podac date, do ktorej chcemy odliczac czas w formacie RRRR-MM-DD.\n	*przyklad: ./dateCounter.sh 2018-10-22\nDodatkowo zamiast daty w powyzszym formacie, skrypt mozna wywolac z parametrem 'jutro', 'wczoraj', 'miesiac':\n	*przyklad: ./dateCounter.sh jutro\nPonadto mozemy sprecyzowac jak ma byc wyswietlany czas - flaga '-c' i potem s (sekundy) lub m (minuty) lub g (godziny) lub d (dni) lub t (tygodnie).\n	*przyklad: ./dateCounter.sh -c s 2018-10-22 (efekt - wyswietlenie czasu w sekundach)\nBez sprecyzowania jak ma byc wyswietlany czas, wyswietlane sa wszystkie wartosci - sekundy, minuty, godziny, dni, tygodnie.\n*Po wywolaniu skryptu wyswietla sie MENU, w ktorym decydujemy czy chcemy wyswietlic obliczony czas jeden raz - wpisz 'o', czy chcemy go automatycznie odliczac - wpisz 'r'.\n*Wszystkie, nieopisane powyzej przypadki/wartosci parametrow sa sygnalizowane bledem.\n";
	printf "**********************************************************\n";
}
function dateError {
	echo 'Blad - zly format daty (Musi byc RRRR-MM-DD!).'
	exit 2;
}

if [ $# -eq 0 ]
then
	echo "Blad - brak argumentow. Zamykam.";
	exit 1;
fi

whatToShow=""
while [ "$1" ]; do
	case "$1" in
		-h|--help)
			helper; exit 0;;
		-c)
			shift
			whatToShow=$1;;
		teraz)
			date="today";;
		jutro)
			date="tomorrow";;
		wczoraj)
			date="yesterday";;
		miesiac)
			date="next-month";;
		-*)
			echo 'Blad - zly argument. Zamykam.'; exit 1;;
		*)
			date="$1";;
	esac

	shift
done

#check if date is text
if [[ $date == [[:alpha:]] ]]
then
    dateError
fi

#if grep -q "[a-z]" <<< "$date"
#then
#   dateError
#fi

#check if date is numb
re='^-?[0-9]+([.][0-9]+)?$'
if [[ $date =~ $re ]]
then
   dateError
fi

/bin/date -d "$date" &> /dev/null || dateError;
endDate="${date:-tomorrow}"

printf "@@@ KALKULATOR DAT @@@\n"
printf "*****************************************\n"

while true ; do
	printf "*Wpisz:\n	r - aby wyswietlic okres RAZ\n	o - aby wyswietlic odliczanie okresu\n"
	read answer

	case "$answer" in
			o)
				echo "*Wybrales odliczanie okresu!";
				printf "*****************************************\n"
				printf "ROZPOCZYNAM ODLICZANIE.\n*Aby przerwac odliczanie i wyjsc z programu kliknij Ctrl+C!\n\n"
				sleep 1
				counterFlag=true;
				break;;
			r)
				printf "*****************************************\n"
				echo "*Wybrales pojedyncze wyswietlenie okresu!";
				break;;
			*)
				printf "$answer - niepoprawna komenda. Sprobuj ponownie.\n";
				printf "*****************************************\n";;
	esac
done

RESULT(){
	sleep 1
	
	sec=$(( $(/bin/date -d "$endDate" +%s) - $(/bin/date +%s) ))
	min=$(( ($(/bin/date -d "$endDate" +%s) - $(/bin/date +%s)) / 60 ))
	hour=$(( ($(/bin/date -d "$endDate" +%s) - $(/bin/date +%s)) / 60 / 60 ))
	days=$(( ($(/bin/date -d "$endDate" +%s) - $(/bin/date +%s)) / 60 / 60 / 24 ))
	weeks=$(( ($(/bin/date -d "$endDate" +%s) - $(/bin/date +%s)) / 60 / 60 / 24 / 7 ))

	printf "*****************************************\n"

if [ $endDate == "yesterday" ]
then
	showEndDate="wczoraj"
elif [ $endDate == "tomorrow" ]
then
	showEndDate="jutra"
elif [ $endDate == "next-month" ]
then
	showEndDate="nastepnego miesiaca"
elif [ $endDate == "today" ]
then
	showEndDate="teraz"
else
	showEndDate=$endDate
fi

	printf "Do $showEndDate pozostalo:\n"

	case "$whatToShow" in
		s)
			echo "	*w sekundach: $sec" ;;
		m)
			echo "	*w minutach: $min";;
		g)
			echo "	*w godzinach: $hour";;
		d)
			echo "	*w dniach: $days";;
		t)
			echo "	*w tygodniach: $weeks";;
		*)
			for i in\
				"	*w sekundach: $sec"\
				"	*w minutach: $min"\
				"	*w godzinach: $hour"\
				"	*w dniach: $days"\
				"	*w tygodniach: $weeks"
			{
				echo "$i"
			} ;;
	esac

	if [ $sec == 0 ]
	then
		showEndDate="teraz"
		printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
		printf "UWAGA! W TYM MOMENCIE JEST $showEndDate! Zamykam.\n"
		exit 0;
	fi
}

if [ $counterFlag ]
then
	while $counterFlag; do
		RESULT
	done
else
	RESULT
fi

exit 0;


