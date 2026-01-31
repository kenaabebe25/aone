package library;

import java.util.List;

/**
 * Central service layer coordinating library operations.
 * SRP: Business rules only.
 * DIP: Depends on repository abstractions.
 */
public class LibraryService {

    public static final double DAILY_FINE = 0.50;
    
    private final MemberRepository memberRepository;
    private final BookRepository bookRepository;
    private final SQLiteBorrowedBookHandler borrowedBookHandler;

    public LibraryService(MemberRepository memberRepository,
                          BookRepository bookRepository) {
        this.memberRepository = memberRepository;
        this.bookRepository = bookRepository;
        this.borrowedBookHandler = new SQLiteBorrowedBookHandler();
    }

    public void registerMember(Member member) {
        memberRepository.save(member);
    }

    public void addBook(Book book) {
        bookRepository.save(book);
    }

    public void removeBook(Book book) {
        bookRepository.deleteData(book.getId());
    }

    public void removeMember(Member member) {
        memberRepository.deleteData(member.getId());
    }

    /**
     * Borrows a book for a member with specified due date.
     * Follows domain rules: sets borrowDate = today, creates BorrowedBook with dueDate.
     */
    public BorrowedBook borrowBook(Member member, Book book, java.time.LocalDate dueDate) {
        // Validate book availability
        if (!book.isAvailable()) {
            throw new IllegalStateException("Book is not available for borrowing.");
        }
        
        // Create borrowed book with domain logic
        BorrowedBook borrowedBook = new BorrowedBook(book, dueDate);
        
        // Update book availability
        book.setAvailable(false);
        
        // Register with member
        member.borrowBook(borrowedBook);

        // Persist to database
        borrowedBookHandler.saveBorrowedBook(member.getId(), borrowedBook);
        memberRepository.save(member);
        bookRepository.save(book);
        
        return borrowedBook;
    }

    /**
     * Calculates fine for a borrowed book based on domain rules.
     * Fine starts the day AFTER the due date at $0.50 per day.
     */
    public double calculateFine(BorrowedBook borrowedBook) {
        if (!borrowedBook.isOverdue()) {
            return 0.0;
        }
        return borrowedBook.daysOverdue() * DAILY_FINE;
    }

    /**
     * Updates member's total fine from all overdue borrowed books.
     * Recalculates total fine (does NOT accumulate repeatedly).
     */
    public void updateMemberFines(Member member) {
        double totalFine = member.getBorrowedBooks().stream()
                .filter(BorrowedBook::isOverdue)
                .mapToDouble(this::calculateFine)
                .sum();
        member.setBalance(totalFine);
        memberRepository.save(member);
    }

    /**
     * Returns a borrowed book following domain rules.
     * Updates fines first, then checks if member has outstanding fines.
     * A book CANNOT be returned if the member has an outstanding fine.
     */
    public void returnBook(Member member, BorrowedBook borrowedBook) {
        // Update fines first
        updateMemberFines(member);
        
        // Check for outstanding fines
        if (member.getBalance() > 0) {
            throw new IllegalStateException("Cannot return book with outstanding fine of $" + 
                String.format("%.2f", member.getBalance()));
        }
        
        // Mark as returned
        borrowedBook.markReturned();
        member.returnBook(borrowedBook);
        
        // Update book availability
        borrowedBook.getBook().setAvailable(true);

        // Persist changes
        borrowedBookHandler.markBookAsReturned(borrowedBook.getBook().getId());
        memberRepository.save(member);
        bookRepository.save(borrowedBook.getBook());
    }

    /**
     * Returns a book by looking up the member's BorrowedBook for it.
     */
    public void returnBook(Member member, Book book) {
        BorrowedBook borrowed = member.getBorrowedBooks().stream()
                .filter(bb -> bb.getBook().getId() == book.getId())
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("Member did not borrow this book."));
        returnBook(member, borrowed);
    }

    /**
     * Clears a member's fine (librarian action).
     */
    public void clearFine(Member member) {
        member.setBalance(0.0);
        memberRepository.save(member);
    }

    /**
     * Processes a fine payment for a member.
     */
    public void payFine(Member member, double amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Payment amount must be positive.");
        }
        member.payFine(amount);
        memberRepository.save(member);
    }

    public List<Book> getAllBooks() {
        return bookRepository.findAll();
    }

    public List<Member> getAllMembers() {
        return memberRepository.findAll();
    }

    /**
     * Builds report data from the database only.
     */
    public LibraryReport getReport() {
        int totalBooks = bookRepository.findAll().size();
        int totalMembers = memberRepository.findAll().size();
        return new LibraryReport(totalBooks, totalMembers);
    }
}
