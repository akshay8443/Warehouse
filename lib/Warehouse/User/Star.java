import java.util.Scanner;

class Star {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.print("Enter numbers: ");
        int n = sc.nextInt();
        int i;
        int j;
        int k;
        for (i = 1; i <= 4; i++) {
            for (j = 3; j >= i; j--) {
                System.out.print(" ");
            }
            for (k = 1; k <= i; k++) {
                System.out.print(" *");
            }
            System.out.println();
        }
    }
}