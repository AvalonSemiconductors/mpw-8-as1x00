public class GenPLA {
	public static void main(String[] args) {
		int and_terms = 30;
		int or_terms = 16;
		int in_size = 8;
		
		String in_name = "ins_in";
		String ands_name = "ins_pla_ands";
		String ors_name = "ins_pla_ors";

		System.out.println("wire [" + (in_size * 2 - 1) + ":0] pla_ins = {");
		for(int i = 0; i < in_size; i++) {
			System.out.println("    " + in_name + "[" + i + "],");
			System.out.print("    ~" + in_name + "[" + i + "]");
			if(i != in_size - 1) System.out.print(",");
			System.out.println();
		}
		System.out.println("};");
		System.out.println();
		
		System.out.println("wire [" + (and_terms - 1) + ":0] and_outs = {");
		for(int i = 0; i < and_terms; i++) {
			for(int j = 0; j < in_size * 2; j++) {
				System.out.print("    ");
				if(j != 0) System.out.print("    ");
				System.out.print("(pla_ins[" + j + "] | ~" + ands_name + "[" + i + "][" + j + "])");
				if(j == in_size * 2 - 1) {
					if(i != and_terms - 1) System.out.print(",");
					System.out.println();
				}else {
					System.out.println(" &");
				}
			}
		}
		System.out.println("};");
		System.out.println();
		
		System.out.println("wire [" + (or_terms - 1) + ":0] or_outs = {");
		for(int i = 0; i < or_terms; i++) {
			for(int j = 0; j < and_terms; j++) {
				System.out.print("    ");
				if(j != 0) System.out.print("    ");
				System.out.print("(" + ors_name + "[" + i + "][" + j + "] & and_outs[" + i + "])");
				if(j == and_terms - 1) {
					if(i != or_terms - 1) System.out.print(",");
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
