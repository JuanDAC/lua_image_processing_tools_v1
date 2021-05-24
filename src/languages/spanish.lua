return {
	lang="es";
	interfaces={
		loader={
			title="carga";
			text="cargando...";
		};
		menu={
			maximize={
				text="Maximizar";
			};
			minimize={
				text="Minimizar";
			};
			close={
				text="Cerrar";
			};
			close_content={
				title="¡Advertencia!";
				text="Esta seguro de cerrar la herramienta";
				buttons={"Mmm ...Estoy seguro", "¡Quiero disfrutar más!"};
			};
			separator_setting={
				text="Configuración";
			};
			languages={
				text="Lenguaje";
			};
			apply_changes={
				text="Aplicar";
			};
		};
		home={
			title="Menu";
			separator_menu={
				text="Menu";
			};
			submit_gadgets={
				text="Utilidades";
			};
			submit_color={
				text="Color";
			};
			submit_adjustment={
				text="Ajustes";
			};
			submit_transform={
				text="Transformaciones";
			};
			submit_filters={
				text="Filtros";
			};
			submit_layer={
				text="Capa";
			};
			submit_animation={
				text="Animación";
			};
			submit_objects={
				text="Objectos";
			};
			submit_3d={
				text="3D";
			};
		};
		color={
			title="Color";
			separator_color={
				text="Color";
			};
			check_picker={
				text="Picker";
			};
			color_picker={
				text="Color picker";
			};
			color_picker_add={
				text="Add";
			};
			check_harmonies={
				text="Armonías de cromáticas";
			};
			combobox_harmonies={
				text="Aplicar";
				options={
					analogs="Analogos",
					complementary="Complementarios",
					split_complementary="Complementarios cercanos",
					compounds="Compuestos",
					squares="Cuadrados",
					complementary_doubles="Dobles complementarios",
					monochromaticos="Monocromaticos",
					tones="Tonos",
					shades="Sombra",
					triad="Triada",
					complementary_triad="Triada complementaria",
				}
			};
			submit_color_foreground_picker={
				text="Color primario"
			};
			submit_color_background_picker={
				text="Color segundario"
			};
			submit_add_palette={
				text="Agregar Paleta de color"
			};
			check_blending={
				text="Mezclador de colores";
			};
			submit_blend_colors={
				text="Mezclar colores";
			};
			balance_blend_colors={
				text="Balance"
			};
			result_blend_colors={
				text="Resultado"
			};
			number_of_colors={
				text="Numero de colores";
			};
			check_gradient={
				text="Generar degradado";
			};
			check_contrast={
				text="Contraste idoneo";
			};
			current_contrast={
				text="Contraste: "
			};
			text_contrast={
				text="Para textos: "
			};
			text_best_contrast={
				text="Mejordo en textos: "
			};
			color_blind_contrast={
				text="Alto contraste: "
			};
			submit_contrast={
				text="Contraste"
			};
			check_extractor={
				text="Extractor de color";
			};
		};

		filters={
			-- check_color={
			-- 	text="Filtros de color";
			-- };
			title="Filters";
			separator_filter={
				text="Filtros";
			};
			combobox_filters={
				text="Seleccionar";
				options={
					grayscale="Escala de gris",
					maximum_gray="Gris maximo",
					minimal_gray="Gris minimo",
					negative="Negativo",
					black_and_white="Blanco y negro",
					transposed="Traspuesta",
					color_component="Componente de color",
					chromatic_aberration="Aberración cromática",
					squares="Cuadrados",
					gamma="Gamma",
					colorize="Colorizar",
					colors_gradient="Gradiente de colores",
					brightness="Brillo",
					contrast="Contraste",
					filp_horizontal="Filp horizontal",
					noise="Ruido",
					mosaic="Mosaico",
					transparency="Transparencia",
				};
				alert="Necesitas escoger un filtro.";
				-- historigrama="Historigrama",
			};
			combobox_context={
				text="Seleccionar";
				options={
					selection="Selección",
					active_frame="Frame activo",
					active_layer="Layer activo",
					active_cel="Cel activo",
					active_cels="Active cels",
					active_file="Archivo activo",
				};
				alert="Necesitas escoger una ubicación para aplicar el filtro.";
			};
			combobox_export={
				text="Seleccionar";
				options={
					export_group="Grupo nuevo",
					export_frame="Frame nuevo",
					export_layer="Layer nuevo",
					export_cel="Cel nuevo",
					export_animation="Animación nuevo",
					export_archive="Archivo nuevo",
				};
				alert="Necesitas escoger una ubicación de exportacion.";
			};
			combobox_type_filter_colorize={
				text="Seleccionar tipo";
				options={
					default="Promedio",
					maximum="Maximo",
					minimum="Minimo",
				};
			};
			apply_filter={
				text="Aplicar filtro";
			};
		};

		genericts_component={
			boolean={
				["true"]="Si";
				["false"]="No";
			}
		};


	};
}




