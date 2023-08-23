import MuiThemeProvider from '@/components/providers/MuiThemeProvider';
import { Roboto } from 'next/font/google';
import '../styles/globals.scss';

const font = Roboto({
	weight: ['100', '300', '400', '500', '700', '900'],
	style: ['normal', 'italic'],
	subsets: ['latin', 'latin-ext'],
	display: 'swap'
});

export default function RootLayout({ children }: { children: React.ReactNode }) {
	return (
		<html lang='en'>
			<head>
				<link rel='icon' type='image/png' href='/favicon.png' />
				<link rel='shortcut icon' type='image/png' href='/favicon.png' />
			</head>
			<body className={font.className} suppressHydrationWarning={true}>
				<MuiThemeProvider>{children}</MuiThemeProvider>
			</body>
		</html>
	);
}
