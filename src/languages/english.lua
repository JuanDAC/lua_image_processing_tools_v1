return {
	lang="en";
	interfaces={
		loader={
			title="loader";
			text="loading...";
		};
		menu={
			maximize={
				text="Maximize";
			};
			minimize={
				text="Minimize";
			};
			close={
				text="Close";
			};
			close_content={
				title="Warning!";
				text="You are sure to close the plugin";
				buttons={"Mmm ...I'm sure", "I want to enjoy more!"};
			};
			separator_setting={
				text="Setting";
			};
			languages={
				text="Language";
			};
			apply_changes={
				text="Apply";
			};
		};
		home={
			title="Menu";
			separator_menu={
				text="Menu";
			};
			submit_gadgets={
				text="Gadgets";
			};
			submit_color={
				text="Color";
			};
			submit_adjustment={
				text="Adjustment";
			};
			submit_transform={
				text="Transformations";
			};
			submit_filters={
				text="Filters";
			};
			submit_layer={
				text="Layer";
			};
			submit_animation={
				text="Animation";
			};
			submit_objects={
				text="Objects";
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
				text="Chromatic harmonies";
			};
			combobox_harmonies={
				text="Apply";
				options={
					analogs="Analogs",
					split_complementary="Split complementary",
					complementary="Complementary",
					complementary_doubles="Complementary doubles",
					complementary_triad="Complementary triad",
					compounds="Compounds",
					monochromaticos="Monochromaticos",
					squares="Squares",
					tones="Tones",
					shades="Shades",
					triad="Triad",
				};
			};
			submit_color_foreground_picker={
				text="Foreground color"
			};
			submit_color_background_picker={
				text="Background color"
			};
			submit_add_palette={
				text="Add palette"
			};
			check_blending={
				text="Colors blending";
			};
			submit_blend_colors={
				text="Blend colors";
			};
			balance_blend_colors={
				text="Balance"
			};
			result_blend_colors={
				text="Resulting color";
			};
			number_of_colors={
				text="Number of colors";
			};
			check_gradient={
				text="Gradient generator";
			};
			check_contrast={
				text="Adequate contrast";
			};
			current_contrast={
				text="Contrast: "
			};
			text_contrast={
				text="Texts: "
			};
			text_best_contrast={
				text="Improved in texts: "
			};
			color_blind_contrast={
				text="High contrast: "
			};
			submit_contrast={
				text="Contrast"
			};
			check_extractor={
				text="Color extractor";
			};
		};



		filters={
			-- check_color={
			-- 	text="Filtros de color";
			-- };
			title="Filters";
			separator_filter={
				text="Filters";
			};
			combobox_filters={
				text="Select";
				options={
					grayscale="Grayscale",
					maximum_gray="Maximum gray",
					minimal_gray="Minimal gray",
					negative="Negative",
					black_and_white="Black and white",
					transposed="Transposed",
					color_component="Color component",
					split_complementary="Split complementary",
					chromatic_aberration="Chromatic aberration",
					squares="Squares",
					gamma="Gamma",
					colorize="Colorize",
					colors_gradient="Colors gradient",
					brightness="Brightness",
					contrast="Contrast",
					filp_horizontal="Filp horizontal",
					noise="Noise",
					mosaic="Mosaic",
					transparency="Transparency",
				};
				alert="You need to choose a filter.";
				-- historigrama="Historigrama",
			};
			combobox_context={
				text="Select";
				options={
					selection="Selection",
					active_frame="Active frame",
					active_layer="Active layer",
					active_cel="Active cel",
					active_cels="Active cels",
					active_file="Active file",
				};
				alert="Necesitas escoger una ubicación para aplicar el filtro.";
			};
			combobox_export={
				text="Select";
				options={
					export_group="New group",
					export_layer="New layer",
					export_frame="New Frame",
					export_cel="New cel",
					export_animation="New animation",
					export_archive="New file",
				};
				alert="You need to choose an export location.";
			};
			combobox_type_filter_colorize={
				text="Select type";
				options={
					default="Default",
					maximum="Maximum",
					minimum="Minimum",
				};
			};
			apply_filter={
				text="Apply filter";
			};
		};



		genericts_component={
			boolean={
				["true"]="True";
				["false"]="false";
			}
		};
	}
}
















