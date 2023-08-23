'use client';

import { ThemeProvider, createTheme } from '@mui/material/styles';
import { PropsWithChildren } from 'react';

const theme = createTheme({
	typography: {
		fontFamily: 'inherit'
	},
	palette: {
		primary: {
			main: '#000000'
		},
		secondary: {
			main: '#FFFFFF'
		}
	}
});

export default function MuiThemeProvider({ children }: PropsWithChildren) {
	return <ThemeProvider theme={theme}>{children}</ThemeProvider>;
}
