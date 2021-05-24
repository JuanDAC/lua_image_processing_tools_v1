
--   Dialog{ title=string, onclose=function }
import getn from table

export class Interface 
	pIds: {
		length: 0
	}

	pColor: {
		length: 0
	}

	pButton: {
		length: 0
	}

	pCheck: {
		length: 0
	}

	pCombobox: {
		length: 0
	}

	pEntry: {
		length: 0
	}

	pLabel: {
		length: 0
	}

	pNumber: {
		length: 0
	}

	pRadio: {
		length: 0
	}

	pSeparator: {
		length: 0
	}
	
	getId: => 
		return @pIds.length

	setId: => 
		@pIds.length += 1
	
	new: (title) => 
		@setId!
		@pId = @getId!
		@pDlg = Dialog title
	
	mColor: (
		label="Color #{@pColor.length}"
	) =>
		@pDlg\color {
			id: "color_#{@pColor.length}",
			label:label, color: app.Color
		}
		@pColor.length += 1

	mButton: (
		label = "Button #{@pButton.length}", 
		text="Button #{@pButton.length}", 
		onclick= -> app.alert(text),
		selected=false, 
		focus=false
	) => 
		@pDlg\button {
			id: "button_#{@pButton.length}",
			label: label,
			text: text,
			selected: selected,
			focus: focus,
			onclick: onclick
		}
		@pButton.length += 1

	mCheck: (
		label="Check #{@pCheck.length}",
		text="Check #{@pCheck.length}",
		onclick= -> app.alert(text),
		selected=false
	) => 
		@pDlg\check {
			id: "check_#{@pCheck.length}",
			label: label,
			text: text, 
			selected: selected, 
			onclick: onclick
		}
		@pCheck.length += 1
	
	mPosition: (x, y) => 
		@pDlg.bounds = Rectangle x, y, @pDlg.bounds.width, @pDlg.bounds.height

	mCombobox: (
		label="Combobox #{@pCombobox.length}",
		option="Combobox",
		options={"Combobox", "Combobox"}
	) => 
		@pDlg\combobox {
			id: "combobox_#{@pCombobox.length}",
			label: label,
			option: option,
			options: options
		}
		@pCombobox.length += 1

	mEntry: (
		label="Entry #{@pEntry.length}",
		text="Entry #{@pEntry.length}",
		focus=false 
	) => 
		@pDlg\entry {
			id: "entry_#{@pEntry.length}",
			label: label,
			text: text,
			focus: focus
		}
		@pEntry.length += 1

	mLabel: (
		label="Label #{@pLabel.length}",
		text="Label #{@pLabel.length}"
	) => 
		@pDlg\label {
			id: "label_#{@pLabel.length}",
			label: label,
			text: text
		}
		@pLabel.length += 1
	
	mNumber: (
		label = "Number #{@pNumber.length}",
		text = @pNumber.length,
		decimals = 10
	) => 
		@pDlg\number {
			id: "number_#{@pNumber.length}",
			label: label,
			text: text,
			decimals: decimals
		}
		@pNumber.length += 1

	mRadio: (
		label = "Radio #{@pRadio.length}", 
		text="Radio #{@pRadio.length}", 
		onclick= -> app.alert(text),
		selected=false, 
		focus=false
	) => 
		@pDlg\radio {
			id: "radio_#{@pRadio.length}",
			label: label,
			text: text,
			selected: selected,
			focus: focus,
			onclick: onclick
		}
		@pRadio.length += 1

	mLanguageManager: => 
		@pDlg\combobox {
			id: "lang",
			label:"Idioma",
			option:"es",
			options:{"en","es"}
		}

	mSeparator: (
		label = "Separator #{@pSeparator.length}",
		text = "Separator #{@pSeparator.length}"
	) => 
		@pDlg\separator {
			id: "separator_#{@pSeparator.length}",
			label: label,
			text: text,
		}
		@pSeparator.length += 1
	
	mOK: (
		label=false, 
		text="OK", 
		onclick= -> app.alert(text), 
		selected=false, 
		focus=false
	) => 
		cuurentClick = -> 
			if @pDlg.data.ok 
				onclick @pDlg.data
			else 
				app.alert("Datos incompletos")
		@mButton(
			label,
			text,
			cuurentClick,
			selected,
			focus
			)
	
	mNewrow: => @pDlg\newrow!
	
	mShow: => @pDlg\show!




interface = Interface('Language')
interface\mLanguageManager!
interface\mColor!
interface\mColor!
interface\mColor!
interface\mButton!
interface\mButton!
interface\mButton!
interface\mCheck!
interface\mCheck!
interface\mCheck!
interface\mCombobox!
interface\mCombobox!
interface\mCombobox!
interface\mEntry!
interface\mEntry!
interface\mEntry!
interface\mLabel!
interface\mLabel!
interface\mLabel!
interface\mNumber!
interface\mNumber!
interface\mNumber!
interface\mRadio!
interface\mRadio!
interface\mRadio!
interface\mSeparator!
interface\mSeparator!
interface\mSeparator!
interface\mOK!
interface\mPosition 80, 10
interface\mShow!
