public class LFSR {
	public static void main(String[] args) {
		int reg = 0;
		for(int i = 0; i < 64; i++) {
			boolean putZero = false;
			if(((reg >> 5) & 1) != ((reg >> 4) & 1)) putZero = true;
			if(reg == 0b111111) putZero = true;

			if(putZero) reg = reg << 1;
			else reg = (reg << 1) | 1;
			reg &= 0b111111;
			if(reg < 16) System.out.print("0");
			System.out.println(Integer.toHexString(reg));
		}
	}
}
