public class GenPLA {
	public static void main(String[] args) {
		int and_terms = 20;
		int or_terms = 8;
		int in_size = 5;
		
		String in_name = "O_latch";
		String pla_in_name = "O_pla_ins";
		String ands_name = "O_pla_ands";
		String ors_name = "O_pla_ors";

		System.out.println("wire [" + (in_size * 2 - 1) + ":0] " + pla_in_name + " = {");
		for(int i = in_size - 1; i >= 0; i--) {
			System.out.println("    " + in_name + "[" + i + "],");
			System.out.print("    ~" + in_name + "[" + i + "]");
			if(i != 0) System.out.print(",");
			System.out.println();
		}
		System.out.println("};");
		System.out.println();
		
		System.out.println("wire [" + (and_terms - 1) + ":0] O_and_outs = {");
		for(int i = and_terms - 1; i >= 0; i--) {
			for(int j = 0; j < in_size * 2; j++) {
				System.out.print("    ");
				if(j != 0) System.out.print("    ");
				System.out.print("(" + pla_in_name + "[" + j + "] | ~" + ands_name + "[" + i + "][" + j + "])");
				if(j == in_size * 2 - 1) {
					if(i != 0) System.out.print(",");
					System.out.println();
				}else {
					System.out.println(" &");
				}
			}
		}
		System.out.println("};");
		System.out.println();
		
		System.out.println("wire [" + (or_terms - 1) + ":0] O_or_outs = {");
		for(int i = or_terms - 1; i >= 0; i--) {
			for(int j = 0; j < and_terms; j++) {
				System.out.print("    ");
				if(j != 0) System.out.print("    ");
				System.out.print("(" + ors_name + "[" + i + "][" + j + "] & O_and_outs[" + j + "])");
				if(j == and_terms - 1) {
					if(i != 0) System.out.print(",");
					System.out.println();
				}else {
					System.out.println(" |");
				}
			}
		}
		System.out.println("};");
		System.out.println();
	}
}
